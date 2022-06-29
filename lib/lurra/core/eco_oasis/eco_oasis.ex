defmodule Lurra.Core.EcoOasis do
  defstruct [:id, :name, elements: []]

  def new(map) do
    %__MODULE__{
      id: map.id,
      name: map.name,
      elements: map.elements
        |> Enum.with_index()
        |> Enum.map(fn {element, index} -> Lurra.Core.Element.new(element, index) end)
    }
  end
end
