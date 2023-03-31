defmodule ElixirAOT.Traverser do

  def safe_traverse_module(ast) do
    traverse_result = traverse_module(ast)
    adapt_list(traverse_result)
  end

  def traverse_module({:defmodule, _, [_, [do: body]]}) do
    traverse_module(body)
  end

  def traverse_module({:__block__, _, block}) do
    traverse_block(block)
  end

  def traverse_module({:def, _, [{:when, _, [{fn_name, _, _}, _]}, [do: _]]}) do
    fn_name
  end

  def traverse_module({:def, _, [{fn_name, _, _}, [do: _]]}) do
    fn_name
  end

  def traverse_module(x), do: :skip_traversing

  def traverse_block(block), do: traverse_block(block, [])
  def traverse_block([ast | tail], acc) do
    case traverse_module(ast) do
        :skip_traversing -> traverse_block(tail, acc)
        x -> traverse_block(tail, [x | acc])
    end
  end
  def traverse_block([], acc), do: Enum.reverse(acc)

  def adapt_list(x) when is_list(x), do: List.flatten(x)
  def adapt_list(x), do: adapt_list([x])
end