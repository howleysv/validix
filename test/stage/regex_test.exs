defmodule Validix.Stage.RegexTest do

  use ExUnit.Case, async: true

  import Validix


  test "pass when regex test passes" do
    res = extract!(foo: "that")
      |> required_string(:foo, regex: ~r/that/)
      |> into(%{})
    assert res == %{foo: "that"}

    res = extract!(foo: "2017-04-25")
      |> required_string(:foo, regex: ~r/\d{4}-\d{2}-\d{2}/)
      |> into(%{})
    assert res == %{foo: "2017-04-25"}
  end


  test "fail when regex test fails" do
    res = extract(foo: "that")
      |> required_string(:foo, regex: ~r/this/)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :foo,
      type: :string,
      value: "that",
    } = reason

    res = extract(foo: "2017-4-25")
      |> required_string(:foo, regex: ~r/\d{4}-\d{2}-\d{2}/)
      |> into(%{})
    assert {:error, reason} = res
    assert %{
      reason: :value_not_allowed,
      field: :foo,
      type: :string,
      value: "2017-4-25",
    } = reason
  end

end
