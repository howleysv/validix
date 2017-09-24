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


  defp validate_type_map!(type_map), do: :ok

end
