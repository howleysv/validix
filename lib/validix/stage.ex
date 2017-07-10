defmodule Validix.Stage do

  alias __MODULE__, as: Stage
  alias Validix.Source
  alias Validix.Type

  @type t :: module

  @callback run(Source.t, Type.key, value :: term, opts :: Keyword.t)
      :: {:ok, Source.t, value :: term} | {:error, reason :: term}

end
