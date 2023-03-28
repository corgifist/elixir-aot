defmodule ElixirAOT.Transformator.Macros do
  defmacro binary_op(operation) do
    quote do
      def create_ast({op = unquote(operation), _, [expr1, expr2]}, state) do
        cpp_math_methods = %{
          :+ => "ExMath_add",
          :- => "ExMath_sub",
          :* => "ExMath_mul",
          :/ => "ExMath_div",
          :<> => "ExMath_concatString"
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
        "EX_ENVIRONMENT.push();\n" <>
        create_ast(ast) <>
        ";" <>
        "\n" <>
        "return 0;\n" <>
        "}"

    processed_code =
      ElixirAOT.Processing.get_includes() <>
        "\n" <>
        "extern ExEnvironment EX_ENVIRONMENT;\n" <>
        ElixirAOT.Processing.get_modules() <>
        "\n" <>
        base_code

    ElixirAOT.Processing.terminate()
    processed_code
  end

  def create_ast(ast), do: create_ast(ast, :normal)

  def create_ast({:defmodule, _, [name_alias, [do: body]]}, _) do
    atom_alias = String.to_atom(destruct_alias(name_alias))
    # clause management table
    ElixirAOT.Modules.setup()
    ElixirAOT.Modules.create_table(atom_alias)
    # module functions list
    ElixirAOT.Modules.create_table(:ex_aot_functions_list)
    create_ast(body, {:module, atom_alias})
    module_code = ElixirAOT.Modules.create_module_functions(atom_alias)
    ElixirAOT.Processing.add_module(module_code)
    ElixirAOT.Modules.terminate_module_tables()
    # IO.inspect(:ets.tab2list(:ex_aot_modules), label: "EX_AOT_MODULES")
    ""
  end

  def create_ast({:def, _, [{fn_name, _, args}, [do: body]]}, {:module, module_alias}) do
    clause_name =
      "ExModule_#{atom_to_raw_string(module_alias)}#{atom_to_raw_string(fn_name)}_Clause" <>
        Kernel.inspect(Enum.random(0..@clause_identifier_limit))

    clause_body =
      "ExObject #{clause_name}() {\n" <>
        "ExObject exReturn = EX_NIL();\n" <>
        create_return_block(body) <>
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

    :ets.insert(def_table, {clause_name, clause_body, args, def_original_name})
    :ets.insert(:ex_aot_functions_list, {def_table})
    :ets.insert(String.to_atom(def_original_name), {def_table})
    # IO.inspect(:ets.tab2list(def_table), label: "DEF_TABLE")
    # IO.inspect(:ets.tab2list(:ex_aot_functions_list), label: "EX_AOT_FUNCTIONS_LIST")
    ""
  end

  def create_ast({{:., _, remote_alias}, _, args}, state) do
    create_remote(remote_alias) <> "(#{create_ast(args, state)})"
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

  def create_ast({var_name, _, _}, :match) do
    "EX_VAR(\"#{atom_to_raw_string(var_name)}\")"
  end

  def create_ast({var_name, _, _}, _) do
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

  def create_return_block([], acc), do: "{\n" <> acc <> "}\n"

  def create_return_block([ast | tail], acc) do
    create_return_block(tail, acc <> "exReturn = " <> create_ast(ast) <> ";\n")
  end

  def create_return_block({:__block__, _, body}), do: create_return_block(body, "")
  def create_return_block(expr), do: "exReturn = #{create_ast(expr)};"

  def create_block(block, state), do: create_block(block, "", state)

  def create_block([ast | tail], acc, state) do
    create_block(tail, acc <> "\t" <> create_ast(ast, state) <> ";\n", state)
  end

  def create_block([], acc, _), do: acc

  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")
end
