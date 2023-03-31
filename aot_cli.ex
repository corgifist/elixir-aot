defmodule Fibonacci do
    def fib(0), do: 1
    def fib(1), do: 1
    def fib(n) do
        fib(n - 1) + fib(n - 2)
    end
end
IO.puts(Fibonacci.fib(10))