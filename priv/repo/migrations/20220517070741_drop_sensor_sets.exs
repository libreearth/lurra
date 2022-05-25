defmodule Lurra.Repo.Migrations.DropSensorSets do
  use Ecto.Migration

  def change do
    drop table(:sensor_sets)
  end
end
