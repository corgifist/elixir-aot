defmodule ElixirAOT.Compiler do
  def compile_from_cpp(filename, code) do
    File.write(filename, code)
    executable_name = hd(String.split(filename, "."))

    case System.cmd("g++", [
           "-o",
           executable_name,
           "-Iaotlib/gc/",
           "-L#{File.cwd!()}",
           "aotlib/aotlib.cpp",
           "aotlib/aotmathlib.cpp",
           "aotlib/aotlibkernel.cpp",
           "aotlib/aotlibexceptions.cpp",
           "-lgc",
           filename
         ]) do
      {output, _} -> IO.puts(output)
      _ -> IO.puts("Something unexpected occurred!")
    end
  end
end
