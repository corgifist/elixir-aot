defmodule ElixirAOT.CLI.State do
  defstruct [:prompt, :index]
end

defmodule ElixirAOT.CLI do
  alias ElixirAOT.CLI.State, as: CLIState
  require Logger
  def main(), do: ElixirAOT.CLI.main(0)

  def main(index) do
    prompt = IO.gets("(" <> Kernel.inspect(index) <> ")>>")
    processPrompt(%CLIState{prompt: prompt, index: index})
  end

  def processPrompt(%CLIState{prompt: p, index: i}) do
    cond do
      p == "$exit" -> :exit
      true -> parsePrompt(%CLIState{prompt: p, index: i + 1})
    end
  end

  def parsePrompt(%CLIState{prompt: p, index: i}) do
    case ElixirAOT.code_to_ast(p) do
      :error -> Logger.error("Compilation was terminated"); main(i - 1)
      ast -> 
        result = ElixirAOT.Transformator.transform([], ast)
        IO.inspect(ast)
        IO.puts(result)
        ElixirAOT.Compiler.compile_from_cpp("aot_cli.cpp", result)
        main(i)
    end
  end
end
