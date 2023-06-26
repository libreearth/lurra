defmodule Lurra.Repo.Migrations.AddUserWarnings do
  use Ecto.Migration

  def change do
    create table(:user_last_observer_warning_visits) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :timestamp, :integer

      timestamps()
    end

    create index(:user_last_observer_warning_visits, [:user_id])
  end
end
