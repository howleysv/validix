defprotocol Validix.Stage.Convert do

  @spec as(any, field :: term, type :: Type.key, value :: term, Type.key)
      :: {:ok, value :: term} | {:error, term} | :parent

  def as(_, field, type, value, args)

end


defimpl Validix.Stage.Convert, for: Validix.Type.Core do

  def as(_, field, type, value, to_type) do
    try do
      {:ok, convert(value, to_type)}
    rescue
      e ->
        error = %Validix.Error{
          message: "Converting #{inspect value} to #{inspect to_type} for #{inspect type} field #{inspect field} failed",
          reason: :bad_value,
          field: field,
          type: type,
          value: value,
          cause: e,
          stacktrace: System.stacktrace(),
        }
        {:error, error}
    end
  end


  defp convert(v, :float) when is_integer(v), do: v / 1

  defp convert(v, :string) when is_integer(v), do: v |> Integer.to_string

  defp convert(v, :atom) when is_integer(v), do: v |> convert(:string) |> convert(:atom)

  defp convert(v, :integer) when is_float(v), do: v |> round

  defp convert(v, :string) when is_float(v), do: v |> Float.to_string

  defp convert(v, :atom) when is_float(v), do: v |> convert(:string) |> convert(:atom)

  defp convert(v, :integer) when is_binary(v), do: v |> String.to_integer

  defp convert(v, :atom) when is_binary(v), do: v |> String.to_existing_atom

  defp convert(v, :boolean) when is_binary(v), do: v |> convert(:atom) |> convert(:boolean)

  defp convert(v, :integer) when is_atom(v), do: v |> convert(:string) |> convert(:integer)

  defp convert(v, :string) when is_atom(v), do: v |> Atom.to_string

  defp convert(%MapSet{} = v, :list), do: v |> MapSet.to_list

  defp convert(%MapSet{} = v, :map), do: v |> convert(:list) |> Map.new(&{&1, true})

  defp convert(%_{} = v, :map), do: v |> Map.from_struct

  defp convert(v, :list) when is_map(v), do: v |> Map.to_list

  defp convert(v, :set) when is_map(v), do: v |> Map.keys |> MapSet.new

  defp convert(v, :map) when is_list(v), do: v |> Map.new

  defp convert(v, :set) when is_list(v), do: v |> MapSet.new

  defp convert(v, :tuple) when is_list(v), do: v |> List.to_tuple

  defp convert(v, :list) when is_tuple(v), do: v |> Tuple.to_list

  defp convert(v, :boolean), do: !!v

  defp convert(v, {:list_of, type}), do: v |> convert(:list) |> Enum.map(&convert(&1, type))

  defp convert(v, {:map_of, type}), do: v |> convert(:map) |> convert({:list_of, {:tuple, type}}) |> convert(:map)

  defp convert(v, {:set_of, type}), do: v |> convert({:list_of, type}) |> convert(:set)

  defp convert(v, {:tuple, types}) when tuple_size(v) == tuple_size(types) do
    v
      |> convert(:list)
      |> Enum.zip(Tuple.to_list(types))
      |> Enum.map(fn({v, t}) -> convert(v, t) end)
      |> convert(:tuple)
  end

  ## No known conversion possible
  defp convert(v, _), do: v

end


defimpl Validix.Stage.Convert, for: Any do
  def as(_, _, _, _, _), do: :parent
end
