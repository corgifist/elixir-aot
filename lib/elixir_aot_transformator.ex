defmodule ElixirAOT.Transformator.Macros do
  defmacro binary_op(operation) do
    quote do
      def create_ast({op = unquote(operation), _, [expr1, expr2]}, state) do
        cpp_math_methods = %{
          :+ => "ExMath_add",
          :- => "ExMath_sub",
          :* => "ExMath_mul",
          :/ => "ExMath_div",
          :<> => "ExMath_concatString",
          :< => "ExMath_less",
          :> => "ExMath_greater",
          :<= => "ExMath_lessEqual",
          :>= => "ExMath_greaterEqual",
          :== => "ExMath_equal",
          :!= => "ExMath_notEqual"
        }

        cpp_math_methods[op] <>
          "(" <> create_ast(expr1, state) <> ", " <> create_ast(expr2, state) <> ")"
      end
    end
  end
end

defmodule ElixirAOT.Transformator do
  alias ElixirAOT.Transformator, as: Transformator
  require Transformator.Macros

  @clause_identifier_limit 1_000_000

  def transform(ast) do
    ElixirAOT.Processing.setup()

    base_code =
      "int main() {\n" <>
        "GC_INIT();\n" <>
        "EX_ENVIRONMENT.push();\n" <>
        "try {\n" <>
        create_ast(
          ast,
          {:module, :Kernel_,
           ElixirAOT.Traverser.safe_traverse_module(
             ElixirAOT.code_to_ast(File.read!("aotlib/ex/kernel.ex"))
           ), nil}
        ) <>
        ";\n" <>
        "} catch (ExObject object) {\n" <>
        "throw std::runtime_error(ExObject_ToString(object));\n" <>
        "}\n" <>
        "return 0;\n" <>
        "}"

    processed_code =
      ElixirAOT.Processing.get_includes() <>
        "\n" <>
        "extern ExEnvironment EX_ENVIRONMENT;\n" <>
        ElixirAOT.Processing.get_predefines() <>
        ElixirAOT.Cases.get_cases() <>
        ElixirAOT.Processing.get_modules() <>
        "\n" <>
        base_code

    ElixirAOT.Processing.terminate()
    processed_code
  end

  def create_ast(ast), do: create_ast(ast, :normal)

  def create_ast({:case, _, [match_value, [do: clauses]]}, state) do
    case_identifier = "ExCase" <> to_string(Enum.random(0..@clause_identifier_limit))
    ElixirAOT.Processing.add_predefine("#{case_identifier}(ExObject argument)")
    ElixirAOT.Processing.create_table(String.to_atom(case_identifier))
    append_ets_table(:ex_aot_cases, {String.to_atom(case_identifier)})
    Enum.map(clauses, fn x -> create_ast(x, {:case, case_identifier, state}) end)
    "#{case_identifier}(#{create_ast(match_value, state)})"
  end

  def create_ast({:->, _, [[{:when, _, [pattern, guard]}], body]}, {:case, case_identifier, original_state}) do
    table_atom = String.to_atom(case_identifier)
    append_ets_table(table_atom, {{table_atom, [:clause, pattern, body, guard]}})
    ""
  end

  def create_ast({:->, _, [[pattern], body]}, {:case, case_identifier, original_state}) do
    table_atom = String.to_atom(case_identifier)
    append_ets_table(table_atom, {{table_atom, [:clause, pattern, body, true]}})
    ""
  end

  def create_ast(quote_form = {:quote, _, [[do: body]]}, state) do
    quoted_result = Code.eval_quoted(quote_form, [])
    create_ast(quoted_result, :quote_form)
  end

  def create_ast(tuple, state = :quote_form) when is_tuple(tuple) do
    "EX_TUPLE(#{create_curly_list(Tuple.to_list(tuple), state)})"
  end

  def create_ast(x, :quoted_form) when is_nil(x), do: "EX_NIL()"
  def create_ast(x, :quoted_form) when is_atom(x), do: "EX_ATOM(\"#{x}\")"
  def create_ast(x, :quoted_form) when is_number(x), do: "EX_NUMBER(#{x})"
  def create_ast(x, :quoted_form) when is_binary(x), do: "EX_STRING(\"#{x}\")"
  def create_ast(x, state = :quoted_form) when is_list(x), do: "EX_LIST(#{create_curly_list(x, state)})"

  def create_ast({:require, _, _}, _) do
    # useless for aot compilation
    ""
  end

  def create_ast({:defmacro, _, [{_, _, _}, _]}, _) do
    # useless for aot compilation
    ""
  end

  def create_ast({:not, _, [expr]}, state) do
    "EX_NOT_EXPR(#{create_ast(expr, state)})"
  end

  def create_ast({:raise, _, [exception_alias, argument]}, state) do
    exception = destruct_alias(exception_alias)

    "ExException_#{String.slice(exception, 0..(String.length(exception) - 2))}(#{create_ast(argument, state)})"
  end

  def create_ast({:raise, _, [argument]}, state) do
    "ExException_throw(#{create_ast(argument, state)})"
  end

  def create_ast({:{}, _, tuple}, state) do
    "EX_TUPLE(#{create_curly_list(tuple, state)})"
  end

  def create_ast([{:|, _, [head, tail]}], state = :match) do
    "EX_CONS(#{create_ast(head, state)}, #{create_ast(tail, state)})"
  end

  def create_ast(
        module_ast = {:defmodule, _, [name_alias, [do: body]]},
        state = {:module, _, _, _}
      ) do
    module_ast = ElixirAOT.Guards.quote_ast(module_ast)
    Code.eval_quoted(module_ast, [])
    atom_alias = String.to_atom(destruct_alias(name_alias))
    # clause management table
    ElixirAOT.Modules.setup()
    ElixirAOT.Modules.create_table(atom_alias)
    # module functions list
    ElixirAOT.Modules.create_table(:ex_aot_functions_list)

    ast_result =
      create_ast(
        body,
        {:module, atom_alias, ElixirAOT.Traverser.safe_traverse_module(module_ast), state}
      )

    module_code = ElixirAOT.Modules.create_module_functions(atom_alias)
    ElixirAOT.Processing.add_module(module_code)
    ElixirAOT.Modules.terminate_module_tables()
    atom_alias_as_string = atom_to_raw_string(atom_alias)

    ElixirAOT.Processing.add_purge_target(
      String.to_atom(
        String.slice(atom_alias_as_string, 0..(String.length(atom_alias_as_string) - 2))
      )
    )

    # IO.inspect(:ets.tab2list(:ex_aot_modules), label: "EX_AOT_MODULES")
    ast_result
  end

  # FUNCTIONS WITH GUARDS
  def create_ast(
        {:def, _, [{:when, _, [{fn_name, _, args}, guard]}, [do: body]]},
        state = {:module, module_alias, _, _}
      ) do
    clause_name =
      "ExModule_#{atom_to_raw_string(module_alias)}#{atom_to_raw_string(fn_name)}_Clause" <>
        Kernel.inspect(Enum.random(0..@clause_identifier_limit))

    clause_body =
      "ExObject #{clause_name}() {\n" <>
        "ExObject exReturn = EX_NIL();\n" <>
        create_return_block(body, state) <>
        "\n" <>
        "return exReturn;\n" <>
        "}\n"

    # clause functions table
    def_table = String.to_atom(clause_name)
    def_original_name = "#{atom_to_raw_string(module_alias)}#{atom_to_raw_string(fn_name)}"
    # IO.puts(def_original_name)
    case :ets.whereis(def_table) do
      :undefined ->
        ElixirAOT.Modules.create_table(def_table)
        ElixirAOT.Modules.create_table(String.to_atom(def_original_name))

      _ ->
        :ok
    end

    ElixirAOT.Processing.add_predefine(clause_name <> "()")
    :ets.insert(def_table, {clause_name, clause_body, args, def_original_name, guard, state})
    append_ets_table(:ex_aot_functions_list, {def_table})
    append_ets_table(String.to_atom(def_original_name), {def_table})
    # IO.inspect(:ets.tab2list(def_table), label: "DEF_TABLE")
    # IO.inspect(:ets.tab2list(:ex_aot_functions_list), label: "EX_AOT_FUNCTIONS_LIST")
    ""
  end

  # FUNCTIONS WITHOUT GUARDS
  def create_ast(
        {:def, _, [{fn_name, _, args}, [do: body]]},
        state = {:module, module_alias, _, _}
      ) do
    clause_name =
      "ExModule_#{atom_to_raw_string(module_alias)}#{atom_to_raw_string(fn_name)}_Clause" <>
        Kernel.inspect(Enum.random(0..@clause_identifier_limit))

    clause_body =
      "ExObject #{clause_name}() {\n" <>
        "ExObject exReturn = EX_NIL();\n" <>
        create_return_block(body, state) <>
        "\n" <>
        "return exReturn;\n" <>
        "}\n"

    # clause functions table
    def_table = String.to_atom(clause_name)
    def_original_name = "#{atom_to_raw_string(module_alias)}#{atom_to_raw_string(fn_name)}"
    # IO.puts(def_original_name)
    case :ets.whereis(def_table) do
      :undefined ->
        ElixirAOT.Modules.create_table(def_table)
        ElixirAOT.Modules.create_table(String.to_atom(def_original_name))

      _ ->
        :ok
    end

    ElixirAOT.Processing.add_predefine(clause_name <> "()")
    :ets.insert(def_table, {clause_name, clause_body, args, def_original_name, true, state})
    append_ets_table(:ex_aot_functions_list, {def_table})
    append_ets_table(String.to_atom(def_original_name), {def_table})
    # IO.inspect(:ets.tab2list(def_table), label: "DEF_TABLE")
    # IO.inspect(:ets.tab2list(:ex_aot_functions_list), label: "EX_AOT_FUNCTIONS_LIST")
    ""
  end

  def create_ast(ast = {{:., _, remote_alias}, _, args}, state) do
    case ElixirAOT.Processing.ensure_guard(String.to_atom(create_universal_remote(remote_alias))) do
      true ->
        {macro_result, _} = Code.eval_quoted(
          {
            :__block__,
            [],
            [
              {:require, [], [hd(remote_alias)]},
              quote do
                Macro.expand(var!(transfer_ast), __ENV__)
              end
            ]
          },
          [transfer_ast: ast],
          __ENV__
        )
        create_ast(
          macro_result, state
        )

      false ->
        create_remote(remote_alias) <> "(#{create_ast(args, state)})"
    end
  end

  def create_ast({:__block__, _, block}, state) do
    "{\n" <> create_block(block, state) <> "}\n"
  end

  def create_ast({:=, _, [left, right]}, state) do
    "ExMatch_pattern(#{create_ast(left, :match)}, #{create_ast(right, state)})"
  end

  Transformator.Macros.binary_op(:+)
  Transformator.Macros.binary_op(:-)
  Transformator.Macros.binary_op(:*)
  Transformator.Macros.binary_op(:/)

  Transformator.Macros.binary_op(:<>)

  Transformator.Macros.binary_op(:==)
  Transformator.Macros.binary_op(:!=)
  Transformator.Macros.binary_op(:<)
  Transformator.Macros.binary_op(:>)
  Transformator.Macros.binary_op(:<=)
  Transformator.Macros.binary_op(:>=)

  def create_ast(ast = {fn_name, _, args}, state = {:module, _, _, _}) when is_list(args) do
    case ElixirAOT.Traverser.traverse_state_list(state, {:macro, fn_name}) do
      {:ok, traverse_alias, _} -> 
        create_ast({{:., [], [generate_remote_alias(traverse_alias), fn_name]}, [], args}, state)
      false -> construct_headless_call_ast(ast, state)
    end
  end

  def construct_headless_call_ast(ast = {fn_name, _, args}, state = {:module, _, _, _}) do
    case ElixirAOT.Traverser.traverse_state_list(state, fn_name) do
      {:ok, traverse_alias, atom} ->
        "ExRemote_#{Kernel.to_string(traverse_alias)}#{atom_to_raw_string(fn_name)}(#{create_ast(args, state)})"

      false ->
        "EX_ENVIRONMENT.get(\"#{atom_to_raw_string(fn_name)}\")"
    end
  end

  def create_ast({var_name, _, context}, :match) when is_atom(context) do
    "EX_VAR(\"#{atom_to_raw_string(var_name)}\")"
  end

  def create_ast({var_name, _, context}, _) when is_atom(context) do
    "EX_ENVIRONMENT.get(\"#{atom_to_raw_string(var_name)}\")"
  end

  def create_ast({expr, _}, state) do
    create_ast(expr, state)
  end

  def create_ast(x, _) when is_nil(x), do: "EX_NIL()"
  def create_ast(x, _) when is_atom(x), do: "EX_ATOM(\"#{x}\")"
  def create_ast(x, _) when is_number(x), do: "EX_NUMBER(#{x})"
  def create_ast(x, _) when is_binary(x), do: "EX_STRING(\"#{x}\")"
  def create_ast(x, state) when is_list(x), do: "EX_LIST(#{create_curly_list(x, state)})"

  def create_ast(x, _) do
    Kernel.inspect(x)
  end

  def generate_remote_alias(name) do
    {:__aliases__, [alias: false], Enum.map(Enum.drop(String.split(to_string(name), "_"), -1), fn x -> String.to_atom(x) end)}
  end

  def create_curly_list([object], state, acc),
    do: create_curly_list([], state, acc <> create_ast(object, state))

  def create_curly_list([object | tail], state, acc),
    do: create_curly_list(tail, state, acc <> create_ast(object, state) <> ", ")

  def create_curly_list([], _, acc), do: "{" <> acc <> "}"
  def create_curly_list(x, state), do: create_curly_list(x, state, "")

  def create_parent_args(args, state), do: create_parent_args(args, "", state)

  def create_parent_args([arg], acc, state) do
    create_parent_args([], acc <> create_ast(arg, state), state)
  end

  def create_parent_args([arg | tail], acc, state) do
    create_parent_args(tail, acc <> create_ast(arg, state) <> ", ", state)
  end

  def create_parent_args([], acc, _), do: "(" <> acc <> ")"

  def create_universal_remote([{:__aliases__, _, module}, target]) do
    create_module(module) <> atom_to_raw_string(target)
  end

  def create_remote([{:__aliases__, _, module}, target]) do
    "ExRemote_" <> create_module(module) <> atom_to_raw_string(target)
  end

  def destruct_alias({:__aliases__, _, module}) do
    create_module(module)
  end

  def create_module(module), do: create_module(module, "")

  def create_module([name | tail], acc) do
    create_module(tail, acc <> atom_to_raw_string(name) <> "_")
  end

  def create_module([], acc), do: acc

  def create_return_block([], acc, _), do: "{\n" <> acc <> "}\n"

  def create_return_block([ast | tail], acc, state) do
    create_return_block(tail, acc <> "exReturn = " <> create_ast(ast, state) <> ";\n", state)
  end

  def create_return_block({:__block__, _, body}, state), do: create_return_block(body, "", state)
  def create_return_block(expr, state), do: "exReturn = #{create_ast(expr, state)};"

  def create_block(block, state), do: create_block(block, "", state)

  def create_block([ast | tail], acc, state) do
    create_block(tail, acc <> "\t" <> create_ast(ast, state) <> ";\n", state)
  end

  def create_block([], acc, _), do: acc

  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")

  def append_ets_table(table, function) do
    source = adapt_ets_table_list(:ets.tab2list(table))
    :ets.delete(table)
    :ets.new(table, [:named_table, :ordered_set, :public])
    :ets.insert(table, concat_tuples(source, function))
  end

  def adapt_ets_table_list([]), do: []
  def adapt_ets_table_list(x), do: hd(x)

  def adapt_empty_tuple({}), do: []
  def adapt_empty_tuple([]), do: []
  def adapt_empty_tuple(x), do: Tuple.to_list(x)

  def concat_tuples(a, b) do
    List.to_tuple(adapt_empty_tuple(a) ++ adapt_empty_tuple(b))
  end
end
