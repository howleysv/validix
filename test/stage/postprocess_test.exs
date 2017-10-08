defmodule Validix.Stage.PostprocessTest do

  use ExUnit.Case, async: true

  import Validix


  test "pass when postprocessing completes normally" do
    res = extract!(foo: "that")
      |> required_string(:foo, post: &String.length/1)
      |> into(%{})
    assert res == %{foo: 4}

    res = extract!(bar: :baz)
      |> optional_atom(:bar, post: fn
        (:foo) -> :bar
        (:baz) -> :foo
      end)
      |> into(%{})
    assert res == %{bar: :foo}
  end


  test "fail when postprocessing raises" do
    res = extract(foo: "that")
      |> required_string(:foo, post: &Atom.to_string/1)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :bad_value,
      field: :foo,
      type: :string,
      value: "that",
      cause: %ArgumentError{},
    } = reason

    res = extract(bar: :bar)
      |> optional_atom(:bar, post: fn
        (:foo) -> :bar
        (:baz) -> :foo
      end)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :bad_value,
      field: :bar,
      type: :atom,
      value: :bar,
      cause: %FunctionClauseError{}
    } = reason

    res = extract(baz: %{spam: 42})
      |> required_map_of(:baz, {:atom, :number}, post: fn(map) ->
        extract!(map)
          |> required_float(:spam)
          |> into(%{})
      end)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :bad_value,
      field: :baz,
      type: {:map_of, {:atom, :number}},
      value: %{spam: 42},
      cause: %Validix.Error{
        reason: :bad_type,
        field: :spam,
        type: :float,
        value: 42,
      }
    } = reason
  end

end
