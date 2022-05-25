defmodule Lurra.Repo.Migrations.CreateSensorSets do
  use Ecto.Migration

  def change do
    create table(:sensor_sets) do
      add :name, :string

      timestamps()
    end
  end
end
