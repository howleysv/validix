defmodule Validix.Type.HelpersTest do

  use ExUnit.Case, async: true

  alias Validix.Type.Helpers


  test "construct type map from multiple maps" do
    map1 = %{
      root: nil,
      foo: :root,
      bar: :foo,
      baz: :foo,
    }
    map2 = %{
      {:fooable, :args} => :foo,
      {:barrable, :args} => :bar,
    }
    map3 = %{
      spam: :root,
      bacon: :baz,
      eggs: {:barrable, "arbitrary args"},
    }

    type_map = Helpers.build_type_map!(mod1: map1, mod2: map2, mod3: map3)
    assert Map.merge(map1, map2) |> Map.merge(map3) == type_map
  end


  test "raise when duplicate types in type map" do
    map1 = %{
      root: nil,
      foo: :root,
      bar: :foo,
      baz: :foo,
    }
    map2 = %{
      baz: :root,
    }

    assert_raise ArgumentError, fn ->
      Helpers.build_type_map!(mod1: map1, mod2: map2)
    end
  end


  test "raise when type parent is unknown" do
    map1 = %{
      root: nil,
      foo: :root,
      bar: :baz,
    }

    assert_raise ArgumentError, fn ->
      Helpers.build_type_map!(mod1: map1)
    end
  end


  test "raise when type has circular definition" do
    map1 = %{
      root: nil,
      foo: :baz,
      bar: :foo,
      baz: :bar,
    }

    assert_raise ArgumentError, fn ->
      Helpers.build_type_map!(mod1: map1)
    end
  end

end
