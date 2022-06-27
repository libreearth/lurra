defmodule Lurra.Repo.Migrations.AddLocationTypeToObserverSensors do
  use Ecto.Migration

  def change do

    alter table(:observers_sensors) do
      add :location_type, :string
    end

  end
end
