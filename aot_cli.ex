defmodule MacroTesting do
    defmacro headless(arg) do
        quote do
            IO.puts(to_string(unquote(arg)))
        end
    end

    def main() do
        a = 5
        IO.puts("A: " <> to_string(a))
        IO.puts("begining")
        headless(1)
        MacroTesting.headless(2)
    end
end

MacroTesting.main()