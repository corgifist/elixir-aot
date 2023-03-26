defmodule ElixirAOT.CLI.State do
  defstruct [:prompt, :index]
end

defmodule ElixirAOT.CLI do
  alias ElixirAOT.CLI.State, as: CLIState
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
    ast = Code.eval_string("quote do #{p} end")
    result = ElixirAOT.Transformator.transform([], ast)
    IO.inspect(ast)
    IO.puts(result)
    ElixirAOT.Compiler.compile("aot_cli.cpp", result)
    main(i)
  end
end
