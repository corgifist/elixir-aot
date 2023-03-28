defmodule ElixirAOT.Modules do
  def create_module_functions(_) do
    ElixirAOT.Processing.create_table(:ex_aot_processed_functions)
    functions_list = flat_single_ets(:ex_aot_functions_list)
    create_clauses(functions_list) <> "\n" <> create_managers(functions_list)
  end

  def create_managers(functions), do: create_managers(functions, "")
  def create_managers([], acc), do: acc

  def create_managers([function | tail], acc) do
    [{_, _, _, original_name}] = :ets.lookup(function, atom_to_raw_string(function))

    case :ets.lookup(:ex_aot_processed_functions, original_name) do
      [] ->
        :ets.insert(:ex_aot_processed_functions, {original_name})
        function_clauses = flat_single_ets(String.to_atom(original_name))

        create_managers(
          tail,
          acc <>
            "ExObject ExRemote_#{original_name}(ExObject arguments) {\n" <>
            create_matching(function_clauses) <>
            "throw std::runtime_error(\"cannot find suitable clause for function call!\");\n" <>
            "}\n" <> "\n"
        )

      _ ->
        create_managers(tail, acc)
    end
  end

  def create_matching(clauses), do: create_matching(clauses, "")
  def create_matching([], acc), do: acc

  def create_matching([clause | tail], acc) do
    [{clause, _, args, _}] = :ets.lookup(clause, atom_to_raw_string(clause))

    create_matching(
      tail,
      "\tEX_ENVIRONMENT.push();\n" <>
        "\tif (ExMatch_tryMatch(#{ElixirAOT.Transformator.create_ast(args, :match)}, arguments)) {\n" <>
        "\t\tExObject result = #{Kernel.to_string(clause)}();\n" <>
        "\t\tEX_ENVIRONMENT.pop();\n" <>
        "\treturn result;\n" <>
        "\t}\n" <> acc
    )
  end

  def create_clauses(functions), do: create_clauses(functions, "")
  def create_clauses([], acc), do: acc

  def create_clauses([function | tail], acc) do
    [{_, clause_code, _, _}] = :ets.lookup(function, atom_to_raw_string(function))
    create_clauses(tail, acc <> clause_code <> "\n")
  end

  def flat_single_ets([{function} | tail], acc) do
    flat_single_ets(tail, [function | acc])
  end

  def flat_single_ets([], acc), do: Enum.reverse(acc)
  def flat_single_ets(table), do: flat_single_ets(:ets.tab2list(table), [])

  def reconstruct_clause_name(name), do: hd(String.split(name, "_Clause")) <> "_Clause"

  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")
end
