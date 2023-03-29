defmodule Checker do
    def is_true(x) when x do
        "true yeeeah"
    end
    def is_true(x), do: "not true uhhh"
end

IO.puts(Checker.is_true(:true))
IO.puts(Checker.is_true(:abc))