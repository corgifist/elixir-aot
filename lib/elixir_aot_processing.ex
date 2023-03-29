defmodule ElixirAOT.Processing do
  def setup() do
    # do not remove!
    case :ets.whereis(:ex_aot_ets_registry) do
      :undefined ->
        :ets.new(:ex_aot_ets_registry, [:named_table, :ordered_set, :public])

      _ ->
        :ok
    end

    create_table(:ex_aot_includes)
    create_table(:ex_aot_modules)
    create_table(:ex_aot_predefines)
    add_include("\"aotlib/aotgeneral.h\"")
  end

  def add_include(path), do: :ets.insert(:ex_aot_includes, {path})
  def add_predefine(name), do: :ets.insert(:ex_aot_predefines, {name})
  def add_module(module), do: :ets.insert(:ex_aot_modules, {module})

  def get_modules() do
    get_modules(:ets.tab2list(:ex_aot_modules), "")
  end

  def get_modules([], acc), do: acc

  def get_modules([{module} | tail], acc) do
    get_modules(tail, acc <> module <> "\n\n")
  end

  def get_predefines(), do: get_predefines(:ets.tab2list(:ex_aot_predefines), "")
  def get_predefines([], acc), do: acc

  def get_predefines([{predefine} | tail], acc) do
    get_predefines(tail, acc <> "ExObject #{predefine};\n")
  end

  def get_includes() do
    get_includes(:ets.tab2list(:ex_aot_includes), "")
  end

  def get_includes([], acc), do: acc

  def get_includes([{path} | tail], acc) do
    get_includes(tail, acc <> "#include #{path}\n")
  end

  def terminate_ets_registry(), do: terminate_ets_registry(:ets.tab2list(:ex_aot_ets_registry))
  def terminate_ets_registry([]), do: :ok

  def terminate_ets_registry([{table} | tail]) do
    :ets.delete(table)
    terminate_ets_registry(tail)
  end

  def terminate() do
    terminate_ets_registry()
  end

  def create_table(name) do
    case :ets.whereis(name) do
      :undefined ->
        :ets.new(name, [:named_table, :ordered_set, :public])
        :ets.insert(:ex_aot_ets_registry, {name})

      _ ->
        :ok
    end
  end
end
