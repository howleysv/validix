defprotocol Validix.Stage.Allowed do

  @spec allowed(any, field :: term, type :: Type.key, value :: term, args :: term)
      :: {:ok, value :: term} | {:error, term} | :parent

  def allowed(_, field, type, value, args)

end


defimpl Validix.Stage.Allowed, for: Validix.Type.Core do

  def allowed(_, field, type, value, args) do
    if value in args do
      {:ok, value}
    else
      error = %Validix.Error{
        message: "Value #{inspect value} for #{inspect type} field #{inspect field} is not allowed",
        reason: :value_not_allowed,
        field: field,
        type: type,
        value: value,
      }
      {:error, error}
    end
  end

end


defimpl Validix.Stage.Allowed, for: Any do
  def allowed(_, _, _, _, _), do: :parent
end
