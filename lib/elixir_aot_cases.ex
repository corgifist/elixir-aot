defmodule ElixirAOT.Cases do
    def get_cases() do
        cases_list = ElixirAOT.Modules.flat_single_ets(:ex_aot_cases)
        construct_cases(cases_list)
    end

    def construct_cases(cases), do: construct_cases(cases, "")
    def construct_cases([], acc), do: acc
    def construct_cases([{case_table} | tail], acc) do
        case_ets_list = :ets.tab2list(case_table)
        case_ets_list = Tuple.to_list(hd(case_ets_list))
        case_ets_list = Tuple.to_list(hd(case_ets_list))
        case_ets_list = tl(case_ets_list)
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
        "EX_ENVIRONMENT.push();\n" <>
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
end