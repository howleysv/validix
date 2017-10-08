defmodule Validix.Type.JsonTest do

  use ExUnit.Case, async: true

  import Validix


  test "good json type" do
    for value <- [-123.45, "foobar",
        %{"key1" => [42], "key2" => %{"subkey1" => nil, "subkey2" => "value"}}] do
      res = %{val: value}
        |> extract()
        |> required_json(:val)
        |> into(%{})
      assert {:ok, %{val: value}} == res
    end
  end


  test "bad json type" do
    for value <- [MapSet.new(), %{foo: 5}, {42}, {"key", "value"}] do
      res = %{val: value}
        |> extract()
        |> required_json(:val)
        |> into(%{})
      assert {:error, %{reason: :bad_type}} = res
    end
  end

end
