defmodule Lurra.Repo.Migrations.CreateObserversSensors do
  use Ecto.Migration

  def change do
    create table(:observers_sensors) do
      add :observer_id, references(:observers, on_delete: :nothing)
      add :sensor_id, references(:sensors, on_delete: :nothing)

      timestamps()
    end

    create index(:observers_sensors, [:observer_id])
    create index(:observers_sensors, [:sensor_id])
  end
end
