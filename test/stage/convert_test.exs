defmodule Validix.Stage.ConvertTest do

  use ExUnit.Case, async: true

  import Validix

  ## Test data

  defmodule Struct do
    defstruct [int: 42, str: "123", float: -12.45]
  end


  test "converted types are recognised" do
    res = extract!(foo: "that")
      |> required_atom(:foo, as: :atom)
      |> into(%{})
    assert res == %{foo: :that}

    res = extract(bar: "42")
      |> required_atom(:bar, as: :integer)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :bad_type,
      field: :bar,
      type: :atom,
      value: 42,
    } = reason

    res = extract!(data: %Struct{})
      |> required(:data, as: {:map_of, {:string, :integer}})
      |> into(%{})
    assert res == %{data: %{"int" => 42, "str" => 123, "float" => -12}}
  end


  test "conversion type is used for validation" do
    res = extract!(foo: "that")
      |> required(:foo, as: :atom)
      |> into(%{})
    assert res == %{foo: :that}

    res = extract(bar: %{baz: 42})
      |> required(:bar, as: :integer)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :bad_type,
      field: :bar,
      type: :integer,
      value: %{baz: 42},
    } = reason
  end

end
