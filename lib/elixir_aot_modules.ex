defmodule ElixirAOT.Modules do
  def setup() do
    case :ets.whereis(:ex_aot_module_table_registry) do
      :undefined ->
        :ets.new(:ex_aot_module_table_registry, [:named_table, :ordered_set, :public])

      _ ->
        :ok
    end
  end

  def create_module_functions(_) do
    ElixirAOT.Modules.create_table(:ex_aot_processed_functions)
    functions_list = flat_single_ets(:ex_aot_functions_list)
    create_clauses(functions_list) <> "\n" <> create_managers(functions_list)
  end

  def create_managers([]), do: ""

  def create_managers(functions) do
    create_managers(Tuple.to_list(hd(functions)), "")
  end

  def create_managers([], acc), do: acc

  def create_managers([function | tail], acc) do
    [{_, _, _, original_name, _, _}] = :ets.lookup(function, atom_to_raw_string(function))

    case :ets.lookup(:ex_aot_processed_functions, original_name) do
      [] ->
        :ets.insert(:ex_aot_processed_functions, {original_name})
        function_clauses = flat_single_ets(String.to_atom(original_name))
        ElixirAOT.Processing.add_predefine("ExRemote_#{original_name}(ExObject argumnets)")

        create_managers(
          tail,
          acc <>
            "ExObject ExRemote_#{original_name}(ExObject arguments) {\n" <>
            create_matching(function_clauses) <>
            "ExException_FunctionClauseError(EX_TUPLE({EX_STRING(\"cannot find suitable clause for function\"), EX_ATOM(\"#{original_name}\"), arguments}));\n" <>
            "return EX_NIL();\n" <>
            "}\n" <> "\n"
        )

      _ ->
        create_managers(tail, acc)
    end
  end

  def create_matching(clauses),
    do: create_matching(Tuple.to_list(hd(adapt_tuple_ets_table(clauses))), "")

  def create_matching([], acc), do: acc

  def create_matching([clause | tail], acc) do
    [{clause, _, args, _, guard, state}] = :ets.lookup(clause, atom_to_raw_string(clause))

    create_matching(
      tail,
      acc <>
        "\t\tEX_ENVIRONMENT.push();\n" <>
        "\t\tif (ExMatch_tryMatch(#{ElixirAOT.Transformator.create_ast(args, :match)}, arguments)) {\n" <>
        "\t\t\tif (IS_TRUE(#{ElixirAOT.Transformator.create_ast(guard, state)})) {\n" <>
        "\t\t\t\tExObject result = #{Kernel.to_string(clause)}();\n" <>
        "\t\t\t\tEX_ENVIRONMENT.pop();\n" <>
        "\t\t\t\treturn result;\n" <>
        "\t\t\t};\n" <>
        "\t\t}\n" <>
        "\t\tEX_ENVIRONMENT.pop();\n"
    )
  end

  def create_clauses([]), do: ""

  def create_clauses(functions) do
    create_clauses(Tuple.to_list(hd(functions)), "")
  end

  def create_clauses([], acc), do: acc

  def create_clauses([function | tail], acc) do
    [{_, clause_code, _, _, _, _}] = :ets.lookup(function, atom_to_raw_string(function))
    create_clauses(tail, acc <> clause_code <> "\n")
  end

  def flat_single_ets([function | tail], acc) do
    flat_single_ets(tail, [function | acc])
  end

  def flat_single_ets([], acc), do: Enum.reverse(acc)
  def flat_single_ets(table), do: flat_single_ets(:ets.tab2list(table), [])

  def adapt_tuple_ets_table(tuple), do: adapt_tuple_ets_table(adapt_tuple_to_list(tuple), [])

  def adapt_tuple_ets_table([element | tail], acc) do
    adapt_tuple_ets_table(tail, [element | acc])
  end

  def adapt_tuple_ets_table([], acc), do: acc

  def adapt_tuple_to_list([]), do: []
  def adapt_tuple_to_list({}), do: []
  def adapt_tuple_to_list(x) when is_list(x), do: x
  def adapt_tuple_to_list(x), do: Tuple.to_list(x)

  def reconstruct_clause_name(name), do: hd(String.split(name, "_Clause")) <> "_Clause"

  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")

  def terminate_module_tables(),
    do: terminate_module_tables(:ets.tab2list(:ex_aot_module_table_registry))

  def terminate_module_tables([]), do: :ok

  def terminate_module_tables([{table} | tail]) do
    case :ets.whereis(table) do
      :undefined -> :unexcpected
      _ -> :ets.delete(table)
    end

    terminate_module_tables(tail)
  end

  def create_table(name) do
    case :ets.whereis(name) do
      :undefined ->
        :ets.new(name, [:ordered_set, :named_table, :public])

      _ ->
        :ok
    end

    :ets.insert(:ex_aot_module_table_registry, {name})
  end
end
