defmodule Lurra.Core.EcoOasis do
  defstruct [:name, elements: []]

  def new(map) do
    %__MODULE__{
      name: map.name,
      elements: Enum.map(map.elements, & Lurra.Core.Element.new(&1))
    }
  end
end
