defmodule Validix.Fetch do

  alias Validix.Source


  @spec required_field(Source.t, field :: term, opts :: Keyword.t)
      :: {:ok, Source.t, value :: term} | {:ok, Source.t} | {:error, term}

  def required_field(source, field, opts) do
    nillable? = Source.get_opt(source, opts, :nillable, false)
    case Source.fetch(source, field) do
      :error ->
        error = %Validix.Error{
          message: "Field #{inspect field} is required",
          reason: :field_required,
          field: field,
        }
        {:error, error}
      {:ok, nil} when nillable? ->
        default(source, field, nil, opts)
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
        default(source, field, nil, opts)
      {:ok, nil} when not strict_optionals? ->
        maybe_default(source, field, opts)
      {:ok, value} ->
        {:ok, source, value}
    end
  end


  @spec default(Source.t, field :: term, value :: term, opts :: Keyword.t)
      :: {:ok, Source.t}

  defp default(source, field, value, opts) do
    {:ok, Source.accept(source, field, value, opts)}
  end


  @spec maybe_default(Soruce.t, field :: term, opts :: Keyword.t)
      :: {:ok, Source.t}

  defp maybe_default(source, field, opts) do
    case Keyword.fetch(opts, :default) do
      {:ok, fun} when is_function(fun) -> default(source, field, fun.(), opts)
      {:ok, value} -> default(source, field, value, opts)
      :error -> {:ok, source}
    end
  end

end
