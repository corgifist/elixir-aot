require ElixirAOT.CLI

defmodule ElixirAOT do
  @moduledoc """
  Translates Elixir code to C++ code and then to native executable.
  """
  require Logger

  def code_to_ast(ast) do
    case Code.string_to_quoted(ast) do
      {:ok, ast} ->
        ast

      {:error, {line, message, metadata}} ->
        Logger.error("AOT compilation error at line #{line}")
        Logger.error("* #{message} #{metadata}")
        :error
    end
  end
end
