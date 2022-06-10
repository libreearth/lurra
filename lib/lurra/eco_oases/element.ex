defmodule Lurra.EcoOases.Element do
  use Ecto.Schema
  import Ecto.Changeset

  schema "elements" do
    field :data, :string
    field :name, :string
    field :type, :string
    belongs_to :eco_oasis, Lurra.EcoOases.EcoOasis
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    timestamps()
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:temp_id, :delete, :name, :type, :data])
    |> validate_required([:name, :type])
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
