defmodule Validix.Stage.SizeTest do

  use ExUnit.Case, async: true

  import Validix


  test "pass when size is allowed" do
    res = extract!(foo: [3, 4, 5])
      |> required_list(:foo, allowed_size: 3)
      |> into(%{})
    assert res == %{foo: [3, 4, 5]}

    res = extract!(bar: "hello")
      |> required_string(:bar, allowed_size: 3..7)
      |> into(%{})
    assert res == %{bar: "hello"}

    res = extract!(baz: %{spam: 1, eggs: 3})
      |> required_map(:baz, allowed_size: [2, 4, 8, 16])
      |> into(%{})
    assert res == %{baz: %{spam: 1, eggs: 3}}

    res = extract!(buz: MapSet.new())
      |> required_set(:buz, allowed_size: 0)
      |> into(%{})
    assert res == %{buz: MapSet.new()}
  end


  test "fail when size not allowed" do
    res = extract(foo: [3, 4, 5])
      |> required_list(:foo, allowed_size: 2)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :foo,
      type: :list,
      value: [3, 4, 5],
    } = reason

    res = extract(bar: "hello")
      |> required_string(:bar, allowed_size: 10..20)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :bar,
      type: :string,
      value: "hello",
    } = reason
  end


  test "pass when empty is allowed" do
    res = extract!(foo: [])
      |> required_list(:foo, allow_empty: true)
      |> into(%{})
    assert res == %{foo: []}
  end


  test "pass non-empty when empty not allowed" do
    res = extract!(foo: [42])
      |> required_list_of(:foo, :integer, allow_empty: false)
      |> into(%{})
    assert res == %{foo: [42]}
  end


  test "fail when empty not allowed" do
    res = extract(foo: [])
      |> required_list(:foo, allow_empty: false)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :foo,
      type: :list,
      value: [],
    } = reason

    res = extract(bar: %{})
      |> required_map_of(:bar, {:string, :integer}, allow_empty: false)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :bar,
      type: :map,
      value: %{},
    } = reason
  end


  test "pass when used with unsized types" do
    res = extract!(foo: :bar)
      |> required_atom(:foo, allowed_size: 42)
      |> required_atom(:foo, allow_empty: false)
      |> into(%{})
    assert res == %{foo: :bar}
  end

end
