defmodule Lurra.Repo.Migrations.DeleteFieldLastWarning do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :last_warning_visit
    end
  end
end
