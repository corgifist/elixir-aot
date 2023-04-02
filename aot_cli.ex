defmodule Test do
    defmacro inspect_macro() do
        quote do
            IO.puts("Hello!") 
        end
    end

    def main() do
        IO.puts("Before macro")
        Test.inspect_macro()
    end
end
Test.main()