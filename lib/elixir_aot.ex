require ElixirAOT.CLI

defmodule ElixirAOT do
  @moduledoc """
  Translates Elixir code to C++ code and then to native executable.
  """

  def code_to_ast(ast) do
    case Code.string_to_quoted(ast) do
      {:ok, ast} -> ast
      {:error, {line, message, metadata}} ->
        IO.puts("AOT compilation error at line #{line}")
        IO.puts("* #{message} #{metadata}")
        :error
    end
  end
end
