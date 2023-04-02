defmodule Test do
    defmacro macro() do
        quote do
            IO.puts("Hello, World!")
        end
    end
end

Test.macro()