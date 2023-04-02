defmodule ElixirAOT.Traverser do
  def safe_traverse_module(ast) do
    adapt_list(traverse_module(ast))
  end

  def traverse_module_specific_state_list(nil, _, _) do
    false
  end

  def traverse_module_specific_state_list(module_tuple = {:module, module_alias, _, next_traverse}, module_target, target) do
    case module_alias == module_target do
      true -> traverse_state_list(module_tuple, target)
      false -> traverse_module_specific_state_list(next_traverse, module_target, target)
    end
  end

  def traverse_state_list(nil, _) do
    false
  end

  def traverse_state_list({:module, module_alias, traverse_list, next_traverse}, target) do
    case target in traverse_list do
      true -> {:ok, module_alias, target}
      false -> traverse_state_list(next_traverse, target)
    end
  end

  def traverse_module(x), do: traverse_module(x, nil)

  def traverse_module({:defmodule, _, [module_alias, [do: body]]}, module_name) do
    traverse_module(body, String.to_atom(ElixirAOT.Transformator.destruct_alias(module_alias)))
  end

  def traverse_module({:__block__, _, block}, module_name) do
    traverse_block(block, module_name)
  end

  def traverse_module({:defmacro, _, [{macro_name, _, _}, _]}, module_name) do
    ElixirAOT.Processing.add_guard(String.to_atom(to_string(module_name) <> to_string(macro_name)))
    {:macro, macro_name}
  end

  def traverse_module({:def, _, [{:when, _, [{fn_name, _, _}, _]}, [do: _]]}, _) do
    fn_name
  end

  def traverse_module({:def, _, [{fn_name, _, _}, [do: _]]}, _) do
    fn_name
  end

  def traverse_module(_, _), do: :skip_traversing

  def traverse_block(block, module), do: traverse_block(block, [], module)

  def traverse_block([ast | tail], acc, module) do
    case traverse_module(ast, module) do
      :skip_traversing -> traverse_block(tail, acc, module)
      x -> traverse_block(tail, [x | acc], module)
    end
  end

  def traverse_block([], acc, _), do: Enum.reverse(acc)

  def adapt_list(x) when is_list(x), do: List.flatten(x)
  def adapt_list(x), do: adapt_list([x])
end
