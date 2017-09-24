defmodule Validix.Pipeline do

  alias Validix.Source
  alias Validix.Stage
  alias Validix.Type

  @protocol_fun_arity 5


  ## Generate a static pipeline from the app config
  pipeline = Application.get_env(:validix, :pipeline, [])

  @spec pipeline() :: [Stage.t]

  def pipeline() do
    unquote(pipeline)
  end


  @spec run(Source.t, field :: term, Type.key, value :: term, opts :: Keyword.t)
      :: {Source.t, value :: term}

  def run(source, field, type, value, opts) do
    run(source, field, type, value, pipeline(), opts)
  end


  @spec run(Source.t, field :: term, Type.key, value :: term, [Stage.t], opts :: Keyword.t)
      :: {Source.t, value :: term}

  def run(source, _, _, value, [], _), do: {source, value}

  def run(source, field, type, value, [stage | pipeline], opts) do
    stage_type = try do
      Protocol.assert_protocol!(stage)
      :protocol
    rescue
      ArgumentError -> :runnable
    end
    case run_stage(field, type, value, stage, stage_type, opts) do
      {:ok, value} ->
        run(source, field, type, value, pipeline, opts)
      {:error, reason} ->
        {Source.handle_error(source, reason), value}
    end
  end


  defp run_stage(field, type, value, stage, :runnable, opts) do
    stage.run(field, type, value, opts)
  end

  defp run_stage(field, type, value, stage, :protocol, opts) do
    functions = stage.__protocol__(:functions)
      |> Enum.filter(&(elem(&1, 1) == @protocol_fun_arity))
      |> Enum.map(&elem(&1, 0))
      |> Enum.filter(&Keyword.has_key?(opts, &1))
    run_protocol_fun(field, type, value, stage, functions, opts)
  end


  defp run_protocol_fun(_, _, value, _, [], _), do: {:ok, value}

  defp run_protocol_fun(field, type, value, stage, [fun | rest], opts) do
    case apply_protocol_fun(field, type, value, stage, fun, opts[fun]) do
      {:ok, value} -> run_protocol_fun(field, type, value, stage, rest, opts)
      {:error, _} = error -> error
    end
  end


  defp apply_protocol_fun(field, type, value, stage, fun, args) do
    type_struct = Type.type_module(type) |> struct()
    with :parent <- apply(stage, fun, [type_struct, field, type, value, args]),
    do: apply_protocol_fun(field, Type.parent_type(type), value, stage, fun, args)
  end

end
