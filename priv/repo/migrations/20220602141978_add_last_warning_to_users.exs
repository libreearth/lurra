defmodule Lurra.Repo.Migrations.AddLastWarningToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_warning_visit, :bigint
    end
  end
end
