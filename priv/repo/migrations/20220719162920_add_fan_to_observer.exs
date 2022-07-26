defmodule Lurra.Repo.Migrations.AddFanToObserver do
  use Ecto.Migration

  def change do
    alter table(:observers) do
      add :fan_level, :float
    end
  end
end
