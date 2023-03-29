require ElixirAOT.CLI

defmodule ElixirAOT do
  @moduledoc """
  Translates Elixir code to C++ code and then to native executable.
  """
  require Logger

  def execute_file(filename) do
    source = File.read!(filename)
    ast = code_to_ast(source)
    ElixirAOT.Compiler.compile_from_cpp(hd(String.split(filename, ".")) <> ".cpp", ElixirAOT.Transformator.transform(ast))
    IO.inspect(ast)
    IO.puts(:os.cmd("./#{hd(String.split(filename, "."))}" |> String.to_charlist))
  end

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
