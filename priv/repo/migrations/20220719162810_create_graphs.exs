defmodule Lurra.Repo.Migrations.CreateGraphs do
  use Ecto.Migration

  def change do
    create table(:graphs) do
      add :device_id, :string
      add :sensor_type, :integer
      add :max_value, :float
      add :min_value, :float

      timestamps()
    end

    create unique_index(:graphs, [:device_id, :sensor_type], name: :graphs_unique_index)
  end
end
