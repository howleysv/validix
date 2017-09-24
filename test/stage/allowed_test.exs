defmodule Validix.Stage.AllowedTest do

  use ExUnit.Case, async: true

  import Validix


  test "pass when value in allowed" do
    res = extract!(foo: "that")
      |> required_string(:foo, allowed: ["this", "that", "other"])
      |> into(%{})
    assert res == %{foo: "that"}

    res = extract!(bar: :string)
      |> optional_atom(:bar, allowed: [:string])
      |> into(%{})
    assert res == %{bar: :string}

    res = extract!(baz: 42)
      |> required_integer(:baz, allowed: 1..100)
      |> into(%{})
    assert res == %{baz: 42}

    res = extract!([])
      |> optional_atom(:foo, [:bar])
      |> into(%{})
    assert res == %{}
  end


  test "fail when value not in allowed" do
    res = extract(foo: "that")
      |> required_string(:foo, allowed: ["this", "other"])
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :foo,
      type: :string,
      value: "that",
    } = reason

    res = extract(bar: :string)
      |> optional_atom(:bar, allowed: [:integer])
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :bar,
      type: :atom,
      value: :string,
    } = reason
  end

end
