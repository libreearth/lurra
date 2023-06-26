defmodule Lurra.Repo.Migrations.AddUserWarningsNv do
  use Ecto.Migration

  def change do
    drop table(:user_last_observer_warning_visits)
    create table(:user_last_observer_warning_visits) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :timestamp, :bigint
      add :device_id, :string
      timestamps()
    end

    create index(:user_last_observer_warning_visits, [:user_id, :device_id])
  end
end
