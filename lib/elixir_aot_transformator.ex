defmodule ElixirAOT.Transformator.Macros do
  defmacro binary_op(operation) do
    quote do
      def create_ast({op = unquote(operation), _, [expr1, expr2]}, state) do
        cpp_math_methods = %{
          :+ => "ExMath_add",
          :- => "ExMath_sub",
          :* => "ExMath_mul",
          :/ => "ExMath_div",
          :<> => "ExMath_concatString"
        }

        cpp_math_methods[op] <>
          "(" <> create_ast(expr1, state) <> ", " <> create_ast(expr2, state) <> ")"
      end
    end
  end
end

defmodule ElixirAOT.Compiler do
  def compile(filename, code) do
    File.write(filename, code)
    executable_name = hd(String.split(filename, "."))

    case System.cmd("g++", ["-o", executable_name, "aotlib.cpp", "aotmathlib.cpp", filename]) do
      {output, _} -> IO.puts(output)
      _ -> IO.puts("Something unexpected occurred!")
    end
  end
end

defmodule ElixirAOT.Transformator do
  alias ElixirAOT.Transformator, as: Transformator
  require Transformator.Macros
  defstruct [:includes, :ast]

  @default_includes ["\"aotgeneral.h\""]

  def transform(includes, ast),
    do: transform(%Transformator{includes: @default_includes ++ includes, ast: ast})

  def transform(transformator) do
    create_include(transformator.includes) <>
      "extern ExEnvironment EX_ENVIRONMENT;\n" <>
      "int main() {\n" <>
      "EX_ENVIRONMENT.push();\n" <>
      create_ast(transformator.ast) <>
      ";" <>
      "\n" <>
      "return 0;\n" <>
      "}"
  end

  def create_ast(ast), do: create_ast(ast, :normal)

  def create_ast({{:., _, remote_alias}, _, args}, state) do
    create_remote(remote_alias) <> create_parent_args(args, state)
  end

  def create_ast({:__block__, _, block}, state) do
    "{\n" <> create_block(block, state) <> "}\n"
  end

  def create_ast({:=, _, [left, right]}, state) do
    "ExMatch_pattern(#{create_ast(left, :match)}, #{create_ast(right, state)})"
  end


  Transformator.Macros.binary_op(:+)
  Transformator.Macros.binary_op(:-)
  Transformator.Macros.binary_op(:*)
  Transformator.Macros.binary_op(:/)

  def create_ast({var_name, _, _}, state) when state == :normal do
    "EX_ENVIRONMENT.get(\"#{atom_to_raw_string(var_name)}\")"
  end

  def create_ast({var_name, _, _}, state) when state == :match do
    "EX_ATOM(\"#{atom_to_raw_string(var_name)}\")"
  end

  def create_ast({expr, _}, state) do
    create_ast(expr, state)
  end

  def create_ast(x, _) when is_nil(x), do: "EX_NIL()"
  def create_ast(x, _) when is_atom(x), do: "EX_ATOM(#{x})"
  def create_ast(x, _) when is_number(x), do: "EX_NUMBER(#{x})"
  def create_ast(x, _) when is_binary(x), do: "EX_STRING(\"#{x}\")"
  def create_ast(x, state) when is_list(x), do: "EX_LIST(#{create_curly_list(x, state)})"

  def create_ast(x, _state) do
    Kernel.inspect(x)
  end


  def create_curly_list([object], state, acc), do: 
    create_curly_list([], state, acc <> create_ast(object, state))
  def create_curly_list([object | tail], state, acc),
    do: create_curly_list(tail, state, acc <> create_ast(object, state) <> ", ")
  def create_curly_list([], _, acc), do:  "{" <> acc <> "}"
  def create_curly_list(x, state), do: create_curly_list(x, state, "")

  def create_parent_args(args, state), do: create_parent_args(args, "", state)

  def create_parent_args([arg], acc, state) do
    create_parent_args([], acc <> create_ast(arg, state), state)
  end

  def create_parent_args([arg | tail], acc, state) do
    create_parent_args(tail, acc <> create_ast(arg, state) <> ", ", state)
  end

  def create_parent_args([], acc, _), do: "(" <> acc <> ")"

  def create_remote([{:__aliases__, _, [module]}, target]) do
    "ExRemote_" <> atom_to_raw_string(module) <> "_" <> atom_to_raw_string(target)
  end

  def create_block(block, state), do: create_block(block, "", state)

  def create_block([ast | tail], acc, state) do
    create_block(tail, acc <> "\t" <> create_ast(ast, state) <> ";\n", state)
  end

  def create_block([], acc, _), do: acc

  def create_include(includes), do: create_include(includes, "")

  def create_include([include | tail], acc),
    do: create_include(tail, "#include #{include}\n" <> acc)

  def create_include([], acc), do: acc <> "\n"
  def atom_to_raw_string(atom), do: String.replace(Kernel.inspect(atom), ":", "")
end
