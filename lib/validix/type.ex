defmodule Validix.Type do

  alias Validix.Type.Generated


  @type key :: atom | {atom, term}
  @type type_map :: %{required(name :: key) => parent :: key}

  @callback types() :: type_map
  @callback valid?(key, term) :: {:ok, boolean} | {:any | :all, [{key, term}, ...]}

  defmacro __using__(_) do
    quote do
      @behaviour Validix.Type
      defstruct []
    end
  end


  @spec type_map() :: type_map

  defdelegate type_map(), to: Generated


  @spec type_module(key) :: module

  defdelegate type_module(type), to: Generated


  @spec parent_type(key) :: key

  def parent_type(type), do: Map.fetch!(type_map(), type_lookup_key(type))


  @spec type_lookup_key(key) :: key

  def type_lookup_key({type, _}), do: {type, :args}

  def type_lookup_key(type), do: type

end
