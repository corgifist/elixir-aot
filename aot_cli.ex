defmodule HT do
    def sum_all(list), do: sum_all(list, 0)
    def sum_all([], acc), do: acc
    def sum_all([expr | tail], acc) do
        sum_all(tail, expr + acc)
    end
end

IO.puts(HT.sum_all([1, 2, 3]))