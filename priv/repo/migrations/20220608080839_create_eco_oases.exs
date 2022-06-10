defmodule Lurra.Repo.Migrations.CreateEcoOases do
  use Ecto.Migration

  def change do
    create table(:eco_oases) do
      add :name, :string

      timestamps()
    end
  end
end
