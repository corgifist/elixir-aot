defmodule ElixirAOT.Transformator.Macros do
  defmacro binary_op(operation) do
    quote do
      def create_ast({op = unquote(operation), _, [expr1, expr2]}) do
        create_ast(expr1) <> " " <> atom_to_raw_string(op) <> " " <> create_ast(expr2)
      end
    end
  end
end

defmodule ElixirAOT.Transformator do
  alias ElixirAOT.Transformator, as: Transformator
  require Transformator.Macros
  defstruct [:includes, :ast]

  def transform(includes, ast),
    do: transform(%Transformator{includes: ["\"aotlib.h\""] ++ includes, ast: ast})

  def transform(transformator) do
    create_include(transformator.includes) <>
      "int main() {\n" <>
      create_ast(transformator.ast) <>
      "\n" <>
      "return 0;\n" <>
      "}"
  end

  def create_ast({{:., _, remote_alias}, _, args}) do
    create_remote(remote_alias) <> create_parent_args(args)
  end

  def create_ast({:__block__, _, block}) do
    "{\n" <> create_block(block) <> "}\n"
  end

  Transformator.Macros.binary_op(:+)
  Transformator.Macros.binary_op(:-)
  Transformator.Macros.binary_op(:*)
  Transformator.Macros.binary_op(:/)

  def create_ast({expr, _}) do
    create_ast(expr)
  end

  def create_ast(x) when is_nil(x), do: "EX_NIL()"
  def create_ast(x) when is_atom(x), do: "EX_ATOM(#{x})"
  def create_ast(x) when is_number(x), do: "EX_NUMBER(#{x})"
  def create_ast(x) when is_binary(x), do: "EX_STRING(\"#{x}\")"

  def create_ast(x) do
    Kernel.inspect(x)
  end

  def create_parent_args(args), do: create_parent_args(args, "")

  def create_parent_args([arg], acc) do
    create_parent_args([], acc <> create_ast(arg))
  end

  def create_parent_args([arg | tail], acc) do
    create_parent_args(tail, acc <> create_ast(arg) <> ", ")
  end

  def create_parent_args([], acc), do: "(" <> acc <> ")"

  def create_remote([{:__aliases__, metadata, [module]}, target]) do
    "ExRemote_" <> atom_to_raw_string(module) <> "_" <> atom_to_raw_string(target)
  end

  def create_block(block), do: create_block(block, "")

  def create_block([ast | tail], acc) do
    create_block(tail, acc <> "\t" <> create_ast(ast) <> ";\n")
  end

  def create_block([], acc), do: acc

  def create_include(includes), do: create_include(includes, "")

  def create_include([include | tail], acc),
    do: create_include(tail, "#include #{include}\n" <> acc)

  def create_include([], acc), do: acc <> "\n"
  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")
end
