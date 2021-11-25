defmodule Lurra.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    alter table(:sensors) do
      add :min_val, :float
      add :max_val, :float
    end
  end
end
