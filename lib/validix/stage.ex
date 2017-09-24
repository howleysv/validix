defmodule Validix.Stage do

  alias Validix.Type

  @type t :: module

  @callback run(field :: term, Type.key, value :: term, opts :: Keyword.t)
      :: {:ok, value :: term} | {:error, reason :: term}

end
