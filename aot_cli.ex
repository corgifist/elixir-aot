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
        IO.puts(quote do {:atomic} end)
        headless(1)
        MacroTesting.headless(2)
        IO.puts(quote do a + b end)
        IO.inspect("Hello, World!")
    end
end

MacroTesting.main()