defmodule ValidixTest do

  use ExUnit.Case, async: true

  import Validix


  ## Test data

  defmodule Struct do
    defstruct [int: 42, bin: <<0xfe>>, str: "spam", nil: nil]
  end


  defmodule OtherStruct do
    defstruct [int: 42, bin: <<0xfe>>, str: "spam", nil: nil]
  end


  defmodule Target do
    defstruct [:int, :str, :other]
  end



  test "extract validation into map" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> required_string(:str)
        |> optional_binary(:missing)
        |> into(%{foo: 42})
      assert res == %{foo: 42, int: struct.int, str: struct.str}
    end
  end


  test "extract validation into keywords" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> required_string(:str)
        |> optional_binary(:missing)
        |> into([foo: 42])
      assert res == [foo: 42, int: struct.int, str: struct.str]
    end
  end


  test "extract validation into struct" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> required_string(:str)
        |> optional_binary(:missing)
        |> into(Target)
      assert res == %Target{int: struct.int, str: struct.str}
    end
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> required_string(:str)
        |> optional_binary(:missing)
        |> into(%Target{other: :foo})
      assert res == %Target{int: struct.int, str: struct.str, other: :foo}
    end
  end


  test "extract validation with default" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> optional_string(:other, default: :foo)
        |> into(%{})
      assert res == %{int: struct.int, other: :foo}
    end
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int)
        |> optional_string(:other, default: :foo)
        |> into(Target)
      assert res == %Target{int: struct.int, other: :foo}
    end
  end


  test "extract validation with renaming" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract!(obj)
        |> required_integer(:int, name: :foo)
        |> required_string(:str, name: :bar)
        |> optional_binary(:bin, name: :boz)
        |> optional(:other, default: 42, name: :spam)
        |> into(%{})
      assert res == %{foo: struct.int, bar: struct.str, boz: struct.bin, spam: 42}
    end
  end


  test "validation (of multiple fields) without raising" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      res = extract(obj)
        |> required_integer(:other)
        |> into(%{})
      assert {:error, %{reason: :field_required, field: :other}} = res
    end
    for obj <- objs do
      res = extract(obj)
        |> required_integer(:str)
        |> required_integer(:int)
        |> into(%{})
      assert {:error, reason} = res
      assert %{
        reason: :bad_type,
        field: :str,
        type: :integer,
        value: "spam",
      } = reason
    end
  end


  test "validation (of multiple fields) raising on failure" do
    struct = %Struct{}
    map = Map.from_struct(struct)
    objs = [struct, map, Enum.into(map, [])]
    for obj <- objs do
      assert_raise Validix.Error, fn ->
        extract!(obj)
          |> required_integer(:other)
          |> into(%{})
      end
    end
    for obj <- objs do
      assert_raise Validix.Error, fn ->
        extract!(obj)
          |> required_integer(:str)
          |> required_integer(:int)
          |> into(%{})
      end
    end
  end

end
