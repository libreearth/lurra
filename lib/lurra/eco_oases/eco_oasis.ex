defmodule Lurra.EcoOases.EcoOasis do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lurra.EcoOases.Element

  schema "eco_oases" do
    field :name, :string
    has_many :elements, Lurra.EcoOases.Element

    timestamps()
  end

  @doc false
  def changeset(eco_oasis, attrs) do
    eco_oasis
    |> cast(attrs, [:name])
    |> cast_assoc(:elements, with: &Element.changeset/2)
    |> validate_required([:name])
  end
end
