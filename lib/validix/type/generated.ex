defmodule Validix.Type.Generated do

  alias Validix.Type
  alias Validix.Type.Helpers


  ## Generate a static type map from the app config
  types = Application.get_env(:validix, :types, [])
    |> Enum.map(&{&1, &1.types()})

  type_map = Helpers.build_type_map!(types)


  @spec type_map() :: Type.type_map

  def type_map() do
    unquote(Macro.escape(type_map))
  end


  @spec type_module(Type.key) :: module

  def type_module(type) do
    Enum.find_value(unquote(Macro.escape(types)), fn({mod, map}) ->
      if Map.has_key?(map, Type.type_lookup_key(type)), do: mod
    end)
  end

end