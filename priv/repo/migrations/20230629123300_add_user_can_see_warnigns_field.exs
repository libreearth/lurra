defmodule Lurra.Repo.Migrations.AddUserCanSeeWarningsField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :can_see_warnings, :boolean, default: false
    end
  end
end
