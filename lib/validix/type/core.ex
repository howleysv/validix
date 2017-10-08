defmodule Validix.Type.Core do

  use Validix.Type

  @ruleless_types [:any, :number, :set]


  def types() do
    %{
      {:value, :args} => :any,
      {:struct, :args} => :map,
      {:one_of, :args} => :any,
      {:list_of, :args} => :list,
      {:map_of, :args} => :map,
      {:set_of, :args} => :set,
      {:tuple_of, :args} => :tuple,

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
      tuple: :defined,
    }
  end


  def valid?(type, _) when type in @ruleless_types, do: {:ok, true}

  def valid?(:defined, value), do: {:ok, value != nil}

  def valid?(:integer, value), do: {:ok, is_integer(value)}

  def valid?(:float, value), do: {:ok, is_float(value)}

  def valid?(:boolean, value), do: {:ok, is_boolean(value)}

  def valid?(:atom, value), do: {:ok, is_atom(value) and not is_boolean(value)}

  def valid?(:binary, value), do: {:ok, is_binary(value)}

  def valid?(:string, value), do: {:ok, String.valid?(value)}

  def valid?(:list, value), do: {:ok, is_list(value)}

  def valid?(:map, value), do: {:ok, is_map(value)}

  def valid?(:tuple, value), do: {:ok, is_tuple(value)}

  def valid?({:value, v}, value), do: {:ok, v == value}

  def valid?({:one_of, types}, value) do
    {:any, Enum.map(types, &{&1, value})}
  end

  def valid?({enum_of, type}, value) when enum_of in [:list_of, :set_of] do
    {:all, Enum.map(value, &{type, &1})}
  end

  def valid?({:map_of, {key_type, value_type}}, value) do
    checks = value
      |> Map.to_list
      |> Enum.reduce([], fn({k, v}, acc) ->
        [{key_type, k}, {value_type, v} | acc]
      end)
    {:all, checks}
  end

  def valid?({:tuple_of, types}, value)
      when tuple_size(types) == tuple_size(value) do
    {:all, Enum.zip(Tuple.to_list(types), Tuple.to_list(value))}
  end

  def valid?({:tuple_of, _}, _), do: {:ok, false}

  def valid?({:struct, mod}, %mod{}), do: {:ok, true}

  def valid?({:struct, _}, _), do: {:ok, false}

  def valid?(type, _) do
     raise ArgumentError,  message: "Validation type spec #{inspect type} is invalid"
  end

end
