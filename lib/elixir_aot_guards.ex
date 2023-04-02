defmodule ElixirAOT.Guards do
  def quote_ast({:defmodule, context, [module_alias, [do: body]]}) do
    {:defmodule, context, [module_alias, [do: quote_ast(body)]]}
  end

  def quote_ast({:__block__, context, body}) do
    {:__block__, context, quote_body(body)}
  end

  def quote_ast(
        x =
          {:defmacro, context,
           [{macro_name, macro_context, macro_args}, [do: {:quote, [], [[do: macro_body]]}]]}
      ) do
    # quoted macro definition
    x
  end

  def quote_ast({:defmacro, context, [{macro_name, macro_context, macro_args}, [do: macro_body]]}) do
    {:defmacro, context,
     [{macro_name, macro_context, macro_args}, [do: {:quote, [], [[do: macro_body]]}]]}
  end

  def quote_ast(x), do: x

  def quote_body(ast), do: quote_body(ast, [])

  def quote_body([ast | tail], acc) do
    quote_body(tail, [quote_ast(ast) | acc])
  end

  def quote_body([], acc), do: Enum.reverse(acc)
end
