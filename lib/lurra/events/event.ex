defmodule Lurra.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :device_id, :string
    field :type, :string
    field :payload, :string
    field :timestamp, :integer
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:device_id, :timestamp, :payload, :type])
    #|> validate_required([:h3id, :timestamp, :payload, :type])
  end
end
