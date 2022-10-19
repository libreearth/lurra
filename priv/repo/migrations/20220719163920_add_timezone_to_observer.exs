defmodule Lurra.Repo.Migrations.AddTimezoneToObserver do
  use Ecto.Migration

  def change do
    alter table(:observers) do
      add :timezone, :string
    end
  end
end
