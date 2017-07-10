defmodule Validix.Source do

  alias __MODULE__, as: This

  @type container :: map | Keyword.t

  @opaque t :: %This{
    container: container,
    extracted: Keyword.t,
    opts: Keyword.t,
    error: nil | term,
  }

  defstruct [
    :container,
    :extracted,
    :opts,
    :error,
  ]


  @spec extract(container) :: This.t
  @spec extract(container, opts :: Keyword.t) :: This.t

  def extract(container, opts \\ []) do
    %This{
      container: container,
      extracted: [],
      opts: opts,
    }
  end


  @spec get_opt(This.t, atom, default :: term) :: term

  def get_opt(this, key, default), do: Keyword.get(this.opts, key, default)


  @spec get_opt(This.t, field_opts :: Keyword.t, atom, default :: term) :: term

  def get_opt(%This{opts: src_opts}, field_opts, key, default) do
    case {Keyword.fetch(field_opts, key), Keyword.fetch(src_opts, key)} do
      {{:ok, value}, :error} -> value
      {:error, {:ok, value}} -> value
      {:error, :error} -> default
    end
  end


  @spec fetch(This.t, field :: term) :: {:ok, value :: term} | :error

  def fetch(%This{container: container} = this, field) when is_map(container) do
    allow_stringified_keys? = get_opt(this, :allow_stringified_keys, true)
    case Map.fetch(container, field) do
      {:ok, value} -> {:ok, value}
      :error when allow_stringified_keys? -> Map.fetch(container, to_string(field))
      :error -> :error
    end
  end

  def fetch(%This{container: container}, field) when is_list(container) do
    Keyword.fetch(container, field)
  end


  @spec accept(This.t, field :: term, value :: term) :: This.t

  def accept(this, field, value) do
    %This{this | extracted: [{field, value} | this.extracted]}
  end


  @spec into(This.t, Collectable.t)
      :: Collectable.t | {:ok, Collectable.t} | {:error, term}
  @spec into(This.t, struct | module)
      :: struct | {:ok, struct} | {:error, term}

  def into(%This{error: nil} = this, target) when is_atom(target) do
    output = struct(target, Enum.reverse(this.extracted))
    if get_opt(this, :raise_on_error, false), do: output, else: {:ok, output}
  end

  def into(%This{error: nil} = this, %_{} = target) do
    output = struct(target, Enum.reverse(this.extracted))
    if get_opt(this, :raise_on_error, false), do: output, else: {:ok, output}
  end

  def into(%This{error: nil} = this, target) do
    output = Enum.into(Enum.reverse(this.extracted), target)
    if get_opt(this, :raise_on_error, false), do: output, else: {:ok, output}
  end

  def into(this, _), do: {:error, this.error}


  @spec handle_error(This.t, term) :: This.t | no_return

  def handle_error(this, reason) do
    ## TODO Set this state to error/raise
    %This{this | error: reason}
  end


  @spec has_error?(This.t) :: boolean

  def has_error?(%This{error: error}), do: error != nil

end
