defmodule Lurra.Core.EcoOasis do
  defstruct [:id, :name, elements: []]

  def new(map) do
    %__MODULE__{
      id: map.id,
      name: map.name,
      elements: Enum.map(map.elements, & Lurra.Core.Element.new(&1))
    }
  end
end
