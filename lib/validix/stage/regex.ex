defprotocol Validix.Stage.Regex do

  @spec regex(any, field :: term, type :: Type.key, value :: term, Regex.t)
      :: {:ok, value :: term} | {:error, term} | :parent

  def regex(_, field, type, value, args)

end


defimpl Validix.Stage.Regex, for: Validix.Type.Core do

  def regex(_, field, :string, value, regex) do
    if value =~ regex do
      {:ok, value}
    else
      error = %Validix.Error{
        message: "Value #{inspect value} for field #{inspect field} failed regex #{inspect regex}",
        reason: :value_not_allowed,
        field: field,
        type: :string,
        value: value,
      }
      {:error, error}
    end
  end

  def regex(_, _, :any, value, _), do: {:ok, value}

  def regex(_, _, _, _, _), do: :parent

end


defimpl Validix.Stage.Regex, for: Any do
  def regex(_, _, _, _, _), do: :parent
end
