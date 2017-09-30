defmodule Validix.CoreTypeTest do

  use ExUnit.Case, async: true

  import Validix


  ## Test data

  defmodule Struct do
    defstruct [int: 42, bin: <<0xfe>>, str: "spam", nil: nil]
  end


  defmodule OtherStruct do
    defstruct [int: 42, bin: <<0xfe>>, str: "spam", nil: nil]
  end


  test "good integer type" do
    for value <- [-123, 0, 123] do
      res = %{val: value}
        |> extract()
        |> required_integer(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad integer type" do
    for value <- [3.14, nil, true, "123", :"123", '123', [123], %{}, {123}] do
      res = %{val: value}
        |> extract()
        |> required_integer(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good float type" do
    for value <- [-123.4, 0.0, 123.4, 1.23e-24] do
      res = %{val: value}
        |> extract()
        |> required_float(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad float type" do
    for value <- [42, nil, true, "123.4", :"123.4", '123.4', [123.4], %{}, {123.4}] do
      res = %{val: value}
        |> extract()
        |> required_float(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good number type" do
    for value <- [-123, 0, 123, -123.4, 0.0, 123.4, 1.23e-24] do
      res = %{val: value}
        |> extract()
        |> required_number(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad number type" do
    for value <- [nil, true, "123.4", :"123.4", '123.4', [123.4], %{}, {123.4}] do
      res = %{val: value}
        |> extract()
        |> required_number(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good binary type" do
    for value <- [<<>>, <<0xfe>>, "foo"] do
      res = %{val: value}
        |> extract()
        |> required_binary(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad binary type" do
    for value <- [42, 3.14, nil, true, :foo, 'foo', ["foo"], %{}, {}] do
      res = %{val: value}
        |> extract()
        |> required_binary(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good string type" do
    for value <- ["", "foo"] do
      res = %{val: value}
        |> extract()
        |> required_string(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad string type" do
    for value <- [42, 3.14, nil, true, :foo, 'foo', ["foo"], %{}, {}] do
      res = %{val: value}
        |> extract()
        |> required_string(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res

    end
  end


  test "good atom type" do
    for value <- [:foo, :"bar", :"123"] do
      res = %{val: value}
        |> extract()
        |> required_atom(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad atom type" do
    for value <- [42, 3.14, nil, true, false, "foo", 'foo', ["foo"], %{}, {}] do
      res = %{val: value}
        |> extract()
        |> required_atom(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res

    end
  end


  test "good map type" do
    for value <- [%{}, %{foo: nil}] do
      res = %{val: value}
        |> extract()
        |> required_map(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad map type" do
    for value <- [42, 3.14, nil, true, false, :foo, "foo", 'foo', ["foo"], {}] do
      res = %{val: value}
        |> extract()
        |> required_map(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res

    end
  end


  test "good map of type" do
    for {type, value} <- [
      {{:atom, :integer}, %{foo: 5, bar: 42}},
      {{:integer, :list}, %{42 => ["foo"], -567 => []}},
      {{:string, {:map_of, {:atom, :any}}}, %{"foo" => %{bar: {:ok, 43}}}},
    ] do
      res = %{val: value}
        |> extract()
        |> required_map_of(:val, type)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad map of type" do
    for value <- [42, 3.14, nil, true, false, :foo, "foo", 'foo', ["foo"], {},
                  %{5 => :foo}, %{foo: "bar"}] do
      res = %{val: value}
        |> extract()
        |> required_map_of(:val, {:integer, :string})
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good list type" do
    for value <- [[], 'foo', [1 ,2, 3]] do
      res = %{val: value}
        |> extract()
        |> required_list(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad list type" do
    for value <- [42, 3.14, nil, true, false, :foo, "foo", %{}, {}] do
      res = %{val: value}
        |> extract()
        |> required_list(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good list of type" do
    for {type, value} <- [
      {:string, ["foo", ""]},
      {{:one_of, [:integer, :atom]}, [-2346, :foo, :bar]},
      {:list, [[]]},
    ] do
      res = %{val: value}
        |> extract()
        |> required_list_of(:val, type)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad list of type" do
    for value <- [42, 3.14, nil, true, false, :foo, "foo", %{}, {},
                  [:foo], [123, 42, 123.4]] do
      res = %{val: value}
        |> extract()
        |> required_list_of(:val, :integer)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good tuple type" do
    for value <- [{}, {:foo}, {42, ["foo"], %{}},  {:error, :badarg}] do
      res = %{val: value}
        |> extract()
        |> required_tuple(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad tuple type" do
    for value <- [42, 3.14, nil, true, false, :foo, 'foo', "foo", ["foo"], %{}] do
      res = %{val: value}
        |> extract()
        |> required_tuple(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good tuple of" do
    for {type, value} <- [
      {{:atom}, {:foo}},
      {{:integer, :list, :map}, {42, ["foo"], %{}}},
      {{{:value, :error}, :any}, {:error, :badarg}},
    ] do
      res = %{val: value}
        |> extract()
        |> required_tuple_of(:val, type)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad tuple of type" do
    for value <- [42, 3.14, nil, true, false, :foo, 'foo', "foo", ["foo"], %{}, {"foo"}, {:foo, :bar}] do
      res = %{val: value}
        |> extract()
        |> required_tuple_of(:val, {:atom})
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good struct type" do
    value = %Struct{}
    res = %{val: value}
      |> extract()
      |> required_struct(:val, Struct)
      |> into(%{})
    assert {:ok, %{val: value}} == res
  end


  test "bad struct type" do
    for value <- [42, 3.14, nil, true, false, :foo, 'foo', "foo", ["foo"], %{}, {"foo"}, %OtherStruct{}] do
      res = %{val: value}
        |> extract()
        |> required_struct(:val, Struct)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good set type" do
    value = MapSet.new(["foo", 42])
    res = %{val: value}
      |> extract()
      |> required_set(:val)
      |> into(%{})
    assert {:ok, %{val: value}} == res
  end


  test "bad set type" do
    for value <- [42, 3.14, nil, true, false, :foo, 'foo', "foo", ["foo"], %{}, {"foo"}] do
      res = %{val: value}
        |> extract()
        |> required_set(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good set of type" do
    for {type, value} <- [
      {:string, MapSet.new(["foo", ""])},
      {{:one_of, [:integer, :atom]}, MapSet.new([-2346, :foo, :bar])},
      {:list, MapSet.new([[]])},
    ] do
      res = %{val: value}
        |> extract()
        |> required_set_of(:val, type)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad set of type" do
    for value <- [42, 3.14, nil, true, false, :foo, "foo", %{}, {},
                  MapSet.new([:foo]), MapSet.new([123, 42, 123.4])] do
      res = %{val: value}
        |> extract()
        |> required_set_of(:val, :integer)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good equal value type" do
    value = :foo
    res = %{val: value}
      |> extract()
      |> required_value(:val, :foo)
      |> into(%{})
    assert {:ok, %{val: value}} == res
  end


  test "bad equal value type" do
    for value <- [42, 3.14, nil, true, false, :foo, 'foo', "foo", ["foo"], %{}, {"foo"}] do
      res = %{val: value}
        |> extract()
        |> required_value(:val, :bar)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end


  test "good defined type" do
    for value <- [123, 3.14, :foo, "", "foo", [bar: :buz], %{bar: :buz}] do
      res = %{val: value}
        |> extract()
        |> required_defined(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad defined type" do
    res = %{val: nil}
      |> extract()
      |> required_defined(:val)
      |> into(%{})
    assert {:error, %{reason: :bad_type}} = res
  end


  test "good one of type" do
    for value <- [123, :foo, "", "foo", [bar: :buz], %{bar: :buz}] do
      res = %{val: value}
        |> extract()
        |> required_one_of(:val, [:integer, :atom, :string, :list, :map])
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad one of type" do
    for value <- [42, 3.14, nil, true, false, 'foo', ["foo"], %{}, {"foo"}] do
      res = %{val: value}
        |> extract()
        |> required_one_of(:val, [:atom, :string])
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end

end
