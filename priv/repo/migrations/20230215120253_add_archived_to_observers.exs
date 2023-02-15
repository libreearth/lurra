defmodule Lurra.Repo.Migrations.AddArchivedToObservers do
  use Ecto.Migration

  def change do
    alter table(:observers) do
      add :archived, :boolean, default: false
    end
  end
end
