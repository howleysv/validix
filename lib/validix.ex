defmodule Validix do

  alias Validix.Source
  alias Validix.Type
  alias Validix.Fetch
  alias Validix.Pipeline


  @spec extract(Source.container) :: Source.t
  @spec extract(Source.container, opts :: Keyword.t) :: Source.t

  def extract(container, opts \\ []), do: Source.extract(container, opts)


  @spec extract!(Source.container) :: Source.t
  @spec extract!(Source.container, opts :: Keyword.t) :: Source.t

  def extract!(container, opts \\ []) do
    opts = Keyword.put(opts, :raise_on_error, true)
    Source.extract(container, opts)
  end


  @spec required(Source.t, field :: term) :: Source.t | no_return
  @spec required(Source.t, field :: term, opts :: Keyword.t) :: Source.t | no_return

  def required(source, field, opts \\ []) do
    type = Source.get_opt(source, opts, :as, :any)
    required_field(source, field, type, opts)
  end


  @spec required_field(Source.t, field :: term, type :: Type.key) :: Source.t | no_return
  @spec required_field(Source.t, field :: term, type :: Type.key, opts :: Keyword.t) :: Source.t | no_return

  def required_field(source, field, type, opts \\ []) do
    do_validate(source, field, type, &Fetch.required_field/3, opts)
  end


  @spec optional(Source.t, field :: term) :: Source.t | no_return
  @spec optional(Source.t, field :: term, opts :: Keyword.t) :: Source.t | no_return

  def optional(source, field, opts \\ []) do
    type = Source.get_opt(source, opts, :as, :any)
    optional_field(source, field, type, opts)
  end


  @spec optional_field(Source.t, field :: term, type :: Type.key) :: Source.t | no_return
  @spec optional_field(Source.t, field :: term, type :: Type.key, opts :: Keyword.t) :: Source.t | no_return

  def optional_field(source, field, type, opts \\ []) do
    do_validate(source, field, type, &Fetch.optional_field/3, opts)
  end


  @spec do_validate(Source.t, field :: term, type :: Type.key,
      fetch_fun :: function, opts :: Keyword.t) :: Source.t | no_return

  defp do_validate(source, field, type, fetch_fun, opts) do
    if Source.has_error?(source) do
      source
    else
      case fetch_fun.(source, field, opts) do
        {:ok, source} -> source
        {:error, reason} -> Source.handle_error(source, reason)
        {:ok, source, value} ->
          {source, value} = Pipeline.run(source, field, type, value, opts)
          if Source.has_error?(source),
            do: source,
            else: Source.accept(source, field, value, opts)
      end
    end
  end


  @spec into(Source.t, Collectable.t)
      :: Collectable.t | {:ok, Collectable.t} | {:error, term}
  @spec into(Source.t, struct | module)
      :: struct | {:ok, struct} | {:error, term}

  def into(source, target), do: Source.into(source, target)


  ## Auto generate validation functions from the type map
  for {type, _} <- Type.type_map(), is_atom(type) do
    @spec unquote(String.to_atom("required_#{type}"))(Source.t, field :: term) :: Source.t | no_return
    @spec unquote(String.to_atom("required_#{type}"))(Source.t, field :: term, opts :: Keyword.t) :: Source.t | no_return

    def unquote(String.to_atom("required_#{type}"))(source, field, opts \\ []) do
      required_field(source, field, unquote(type), opts)
    end


    @spec unquote(String.to_atom("optional_#{type}"))(Source.t, field :: term) :: Source.t | no_return
    @spec unquote(String.to_atom("optional_#{type}"))(Source.t, field :: term, opts :: Keyword.t) :: Source.t | no_return

    def unquote(String.to_atom("optional_#{type}"))(source, field, opts \\ []) do
      optional_field(source, field, unquote(type), opts)
    end
  end

  for {{type, _args}, _} <- Type.type_map() do
    @spec unquote(String.to_atom("required_#{type}"))(Source.t, field :: term, args :: term) :: Source.t | no_return
    @spec unquote(String.to_atom("required_#{type}"))(Source.t, field :: term, args :: term, opts :: Keyword.t) :: Source.t | no_return

    def unquote(String.to_atom("required_#{type}"))(source, field, args, opts \\ []) do
      required_field(source, field, {unquote(type), args}, opts)
    end


    @spec unquote(String.to_atom("optional_#{type}"))(Source.t, field :: term, args :: term) :: Source.t | no_return
    @spec unquote(String.to_atom("optional_#{type}"))(Source.t, field :: term, args :: term, opts :: Keyword.t) :: Source.t | no_return

    def unquote(String.to_atom("optional_#{type}"))(source, field, args, opts \\ []) do
      optional_field(source, field, {unquote(type), args}, opts)
    end
  end

end
