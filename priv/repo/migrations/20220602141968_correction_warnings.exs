defmodule Lurra.Repo.Migrations.CreateWarnings do
  use Ecto.Migration

  def change do
    drop table(:warnings)

    create table(:warnings) do
      add :date, :bigint
      add :device_id, :string
      add :sensor_type, :integer
      add :description, :text

      timestamps()
    end
  end
end
