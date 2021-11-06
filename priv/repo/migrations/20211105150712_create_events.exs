defmodule Lurra.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :h3id, :string
      add :timestamp, :utc_datetime
      add :payload, :string
      add :type, :string

      timestamps()
    end
  end
end
