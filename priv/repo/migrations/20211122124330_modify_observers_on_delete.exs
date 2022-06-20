defmodule Lurra.Repo.Migrations.ModifyObserversOnDelete do
  use Ecto.Migration

  def change do
    drop constraint(:observers_sensors, :observers_sensors_observer_id_fkey)

    alter table(:observers_sensors) do
      modify :observer_id, references(:observers, on_delete: :delete_all)
    end
  end
end
