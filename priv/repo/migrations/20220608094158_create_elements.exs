defmodule Lurra.Repo.Migrations.CreateElements do
  use Ecto.Migration

  def change do
    create table(:elements) do
      add :name, :string
      add :type, :string
      add :data, :text
      add :eco_oasis_id, references(:eco_oases, on_delete: :delete_all)

      timestamps()
    end

    create index(:elements, [:eco_oasis_id])
  end
end
