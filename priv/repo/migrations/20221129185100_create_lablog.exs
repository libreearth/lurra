defmodule Lurra.Repo.Migrations.CreateLablogsNv do
  use Ecto.Migration

  def change do
    create table(:lablogs) do
      add :payload, :text
      add :user, :string
      add :timestamp, :bigint

      timestamps()
    end

    create index(:lablogs, [:timestamp])
  end
end
