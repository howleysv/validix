defmodule Validix.Fetch do

  alias Validix.Source


  @spec required_field(Source.t, field :: term, opts :: Keyword.t)
      :: {:ok, Source.t, value :: term} | {:ok, Source.t} | {:error, term}

  def required_field(source, field, opts) do
    nillable? = Source.get_opt(source, opts, :nillable, false)
    case Source.fetch(source, field) do
      :error ->
        {:error, :required_field}
      {:ok, nil} when nillable? ->
        default(source, field, nil)
      {:ok, value} ->
        {:ok, source, value}
    end
  end


  @spec optional_field(Source.t, field :: term, opts :: Keyword.t)
      :: {:ok, Source.t, value :: term} | {:ok, Source.t} | {:error, term}

  def optional_field(source, field, opts) do
    nillable? = Source.get_opt(source, opts, :nillable, false)
    strict_optionals? = Source.get_opt(source, opts, :strict_optionals, false)
    case Source.fetch(source, field) do
      :error ->
        maybe_default(source, field, opts)
      {:ok, nil} when nillable? ->
        default(source, field, nil)
      {:ok, nil} when not strict_optionals? ->
        maybe_default(source, field, opts)
      {:ok, value} ->
        {:ok, source, value}
    end
  end


  @spec default(Source.t, field :: term, value :: term)
      :: {:ok, Source.t}

  defp default(source, field, value) do
    {:ok, Source.accept(source, field, value)}
  end


  @spec maybe_default(Soruce.t, field :: term, opts :: Keyword.t)
      :: {:ok, Source.t}

  defp maybe_default(source, field, opts) do
    case Keyword.fetch(opts, :default) do
      {:ok, fun} when is_function(fun) -> default(source, field, fun.())
      {:ok, value} -> default(source, field, value)
      :error -> {:ok, source}
    end
  end

end
