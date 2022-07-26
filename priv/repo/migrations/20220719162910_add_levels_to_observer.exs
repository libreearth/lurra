defmodule Lurra.Repo.Migrations.AddLevelsToObserver do
  use Ecto.Migration

  def change do
    alter table(:observers) do
      add :min_depth_level, :float
      add :max_depth_level, :float
    end
  end
end
