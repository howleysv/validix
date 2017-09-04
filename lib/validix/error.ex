defmodule Validix.Error do

  alias __MODULE__, as: This


  defexception [
    :message, :reason,
    :field, :type, :value,
    :cause, :stacktrace,
  ]


  def exception(args) do
    struct(This, args)
  end

end
