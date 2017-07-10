defmodule Validix.Pipeline do

  alias Validix.Source
  alias Validix.Stage


  @spec pipeline() :: [Stage.t]

  def pipeline() do
    [
      # Stage.Convert,
      # Stage.Assert,
      # Stage.Allowed,
      # Stage.Regex,
      # Stage.Empty,
      # Stage.Length,
      # Stage.Postprocess,
    ]
  end


  @spec run(Source.t, Type.key, value :: term, opts :: Keyword.t)
      :: {Source.t, value :: term}

  def run(source, type, value, opts) do
    run(source, type, value, pipeline(), opts)
  end


  @spec run(Source.t, Type.key, value :: term, [Stage.t], opts :: Keyword.t)
      :: {Source.t, value :: term}

  def run(source, _, value, [], _), do: {source, value}

  def run(source, type, value, [stage | pipeline], opts) do
    case stage.run(source, type, value, opts) do
      {:ok, source, value} ->
        run(source, type, value, pipeline, opts)
      {:error, reason} ->
        {Source.handle_error(source, reason), value}
    end
  end

end
