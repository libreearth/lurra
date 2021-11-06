defmodule Lurra.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :h3id, :string
    field :payload, :string
    field :timestamp, :utc_datetime
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:h3id, :timestamp, :payload, :type])
    #|> validate_required([:h3id, :timestamp, :payload, :type])
  end
end
