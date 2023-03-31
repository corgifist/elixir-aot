defmodule NestedTraversingTest do
    def first() do
        IO.puts("In " <> to_string(:internal))
        second()
    end

    def second() do
        IO.puts("In " <> hd([2]) <> to_string(:nd))
    end
end

NestedTraversingTest.first()