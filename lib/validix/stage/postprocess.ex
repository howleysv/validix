defprotocol Validix.Stage.Postprocess do

  @spec post(any, field :: term, type :: Type.key, value :: term, ((term) -> term))
      :: {:ok, value :: term} | {:error, term} | :parent

  def post(_, field, type, value, args)

end


defimpl Validix.Stage.Postprocess, for: Validix.Type.Core do

  def post(_, field, type, value, post_fun) do
    try do
      {:ok, post_fun.(value)}
    rescue
      e ->
        error = %Validix.Error{
          message: "Postprocessing #{inspect value} for #{inspect type} field #{inspect field} failed",
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

end


defimpl Validix.Stage.Postprocess, for: Any do
  def post(_, _, _, _, _), do: :parent
end
