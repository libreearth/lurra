defmodule Lurra.Repo.Migrations.CreateObservers do
  use Ecto.Migration

  def change do
    create table(:observers) do
      add :name, :string
      add :device_id, :string

      timestamps()
    end
  end
end
