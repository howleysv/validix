defmodule Validix.Type do

  @type key :: atom | {atom, term}

  @callback type() :: {name :: key, parent :: key}
  @callback valid?(term) :: {:ok, boolean} | :parent
  @callback regex?(term, Regex.t) :: {:ok, boolean} | :parent
  @callback length(term) :: {:ok, integer} | :parent
  @callback convert(term) :: {:ok, term} | :parent

  defmacro __using__(_) do
    quote do
      @behaviour Validix.Type

      def valid?(_), do: :parent
      def regex?(_, _), do: :parent
      def length(_), do: :parent
      def convert(_), do: :parent

      defoverridable [
        valid?: 1,
        regex?: 1,
        length: 1,
        convert: 1,
      ]
    end
  end

  def type_map, do: %{
    ## Parameterised types specified by {type, :args} for matching
    {:value, :args} => :any,
    {:tuple, :args} => :defined,
    {:struct, :args} => :map,
    {:one_of, :args} => :defined,
    {:list_of, :args} => :list,
    {:map_of, :args} => :map,
    {:set_of, :args} => :set,

    any: nil,
    defined: :any,
    integer: :defined,
    float: :defined,
    boolean: :defined,
    atom: :defined,
    binary: :defined,
    string: :binary,
    number: {:one_of, [:integer, :float]},
    list: :defined,
    map: :defined,
    set: {:struct, MapSet},
  }

end
