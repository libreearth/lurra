defmodule Lurra.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :value_type, :string
      add :name, :string
      add :sensor_type, :integer
      add :unit, :string

      timestamps()
    end
  end
end
