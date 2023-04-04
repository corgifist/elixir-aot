defmodule ElixirAOT.Cases do
    def get_cases() do
        cases_list = ElixirAOT.Modules.flat_single_ets(:ex_aot_cases)
        construct_cases(cases_list)
    end

    def construct_cases(cases), do: construct_cases(cases, "")
    def construct_cases([], acc), do: acc
    def construct_cases([{case_table} | tail], acc) do
        case_ets_list = unpack_case(:ets.tab2list(case_table))
        IO.inspect(:ets.tab2list(case_table), label: "PREVIEW")
        condition_construction = Enum.reduce(
            case_ets_list, "",
            fn x, acc -> acc <> construct_case_condition(x) end
        )
        construct_cases(tail, acc <> 
        "ExObject #{to_string(case_table)}(ExObject argument) {\n" <>
        condition_construction <> 
        "ExException_CaseClauseError(argument);\n" <>
        "return EX_NIL();\n" <>
        "}\n")
    end

    def construct_case_condition([:clause, pattern, body, guard]) do
        "EX_ENVIRONMENT.pushCopy();\n" <>
        "if (ExMatch_tryMatch(#{ElixirAOT.Transformator.create_ast(pattern, :match)}, argument)) {\n" <>
        "if (IS_TRUE(#{ElixirAOT.Transformator.create_ast(guard)})) {\n" <>
        "ExObject exReturn = EX_NIL();\n" <>
        "#{ElixirAOT.Transformator.create_return_block(body, :normal)}\n" <>
        "EX_ENVIRONMENT.pop();\n" <>
        "return exReturn;\n" <>
        "}\n" <>
        "}\n" <>
        "EX_ENVIRONMENT.pop();\n"
    end

    def unpack_case(tables) do 
        IO.inspect(tables, label: "TABLES PREVIEW")
        prepare_tables(tables)
    end

    def prepare_tables(tables) do
        tables = hd(tables)
        tables = Tuple.to_list(tables)
        prepare_tables(tables, [])
    end
    def prepare_tables([], acc), do: Enum.reverse(acc)
    def prepare_tables([{_, clause} | tail], acc) do
        prepare_tables(tail, [clause | acc])
    end

    def adapt_to_list([]), do: []
    def adapt_to_list({}), do: []
    def adapt_to_list(x) when is_list(x), do: x
    def adapt_to_list(x), do: Tuple.to_list(x)
end