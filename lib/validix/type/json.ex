defmodule Validix.Type.Json do

  use Validix.Type

  def types() do
    %{
      json_list: {:list_of, :json},
      json_object: {:map_of, {:string, :json}},
      json: {:one_of, [
        :number,
        :string,
        :boolean,
        :json_list,
        :json_object,
        {:value, nil},
      ]},
    }
  end


  def valid?(_, _), do: {:ok, true}

end
