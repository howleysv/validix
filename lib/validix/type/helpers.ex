defmodule Validix.Type.Helpers do

  def build_type_map!(types) do
    type_map = Enum.reduce(types, %{}, fn({_, sub_map}, acc) ->
      Map.merge(acc, sub_map, fn
        (_, value, value) ->
          value
        (key, _, _) ->
          raise ArgumentError,
            message: "Validix configured with duplicate type #{inspect key}"
      end)
    end)
    validate_type_map!(type_map)
    type_map
  end


  defp validate_type_map!(type_map) do
    ## Check all type parents exist
    type_map
      |> Map.values()
      |> Enum.map(fn
        ({type, _}) -> {type, :args}
        (type) -> type
      end)
      |> MapSet.new()
      |> MapSet.delete(nil)
      |> Enum.each(fn(type) ->
        if not Map.has_key?(type_map, type) do
          raise ArgumentError,
            message: "Validix configured with unknown type #{inspect type}"
        end
      end)

    ## Check type map is a valid tree
    type_map
      |> Map.keys()
      |> Enum.reduce(MapSet.new([nil]), &walk_type(type_map, &1, &2, []))

    :ok
  end


  defp walk_type(type_map, {type, args}, processed, walked) when args != :args do
    walk_type(type_map, {type, :args}, processed, walked)
  end

  defp walk_type(type_map, type, processed, walked) do
    cond do
      type in walked ->
        walked = Enum.reverse([type | walked])
        raise ArgumentError,
          message: "Validix configured with circular type spec #{inspect walked}"
      type in processed ->
        processed
      true ->
        parent_type = Map.fetch!(type_map, type)
        processed = MapSet.put(processed, type)
        walk_type(type_map, parent_type, processed, [type | walked])
    end
  end

end
