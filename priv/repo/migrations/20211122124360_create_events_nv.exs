defmodule Lurra.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    drop table(:events)
    create table(:events) do
      add :device_id, :string
      add :type, :string
      add :timestamp, :bigint
      add :payload, :string
    end

    create index(:events, [:timestamp])
  end
end
