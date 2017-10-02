defprotocol Validix.Stage.Size do

  @spec allowed_size(any, field :: term, type :: Type.key, value :: term, length :: integer | Enumerable.t(integer))
      :: {:ok, value :: term} | {:error, term} | :parent

  def allowed_size(_, field, type, value, args)


  @spec allow_empty(any, field :: term, type :: Type.key, value :: term, allow? :: boolean)
      :: {:ok, value :: term} | {:error, term} | :parent

  def allow_empty(_, field, type, value, args)

end


defimpl Validix.Stage.Size, for: Validix.Type.Core do

  @size_types [:binary, :string, :list, :map, :set, :tuple]

  def allowed_size(_, field, type, value, size) when type in @size_types do
    value_size = size(value)
    allowed? = if is_integer(size), do: value_size == size, else: value_size in size
    if allowed? do
      {:ok, value}
    else
      error = %Validix.Error{
        message: "Size #{value_size} #{type} #{inspect value} not allowed for field #{inspect field}",
        reason: :value_not_allowed,
        field: field,
        type: type,
        value: value,
      }
      {:error, error}
    end
  end

  def allowed_size(_, _, :any, value, _), do: {:ok, value}

  def allowed_size(_, _, _, _, _), do: :parent


  def allow_empty(_, _, _, value, true), do: {:ok, value}

  def allow_empty(_, field, type, value, false) when type in @size_types do
    if size(value) > 0 do
      {:ok, value}
    else
      error = %Validix.Error{
        message: "Empty #{inspect type} #{inspect value} not allowed for field #{inspect field}",
        reason: :value_not_allowed,
        field: field,
        type: type,
        value: value,
      }
      {:error, error}
    end
  end

  def allow_empty(_, _, :any, value, _), do: {:ok, value}

  def allow_empty(_, _, _, _, _), do: :parent


  defp size(value) when is_binary(value) do
    if String.valid?(value), do: String.length(value), else: byte_size(value)
  end

  defp size(value) when is_list(value), do: length(value)

  defp size(value = %MapSet{}), do: MapSet.size(value)

  defp size(value) when is_map(value), do: map_size(value)

  defp size(value) when is_tuple(value), do: tuple_size(value)

end


defimpl Validix.Stage.Size, for: Any do
  def allowed_size(_, _, _, _, _), do: :parent
  def allow_empty(_, _, _, _, _), do: :parent
end
