defmodule Lurra.Repo.Migrations.AddElementToObserverSensors do
  use Ecto.Migration

  def change do

    alter table(:observers_sensors) do
      add :element_id, references(:elements, on_delete: :nilify_all)
    end

    create index(:observers_sensors, [:element_id])
  end
end
