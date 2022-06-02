defmodule Lurra.Repo.Migrations.CreateTriggers do
  use Ecto.Migration

  def change do
    create table(:triggers) do
      add :name, :string
      add :device_id, :string
      add :sensor_type, :integer
      add :rule, :text
      add :actions, :text

      timestamps()
    end
  end
end
