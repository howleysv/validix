defmodule Validix.Type do

  @type key :: atom | {atom, term}

  @callback types() :: %{required(name :: key) => parent :: key}
  @callback valid?(key, term) :: {:ok, boolean} | {:any | :all, [{key, term}, ...]}

  defmacro __using__(_) do
    quote do
      @behaviour Validix.Type
      defstruct []
    end
  end


  def type_map, do: Validix.Type.Core.types()


  @spec parent_type(key) :: {:ok, key} | :error

  def parent_type({type, _args}), do: Map.fetch(type_map(), {type, :args})

  def parent_type(type), do: Map.fetch(type_map(), type)


  @spec type_module(key) :: module

  def type_module(_), do: Validix.Type.Core

end
