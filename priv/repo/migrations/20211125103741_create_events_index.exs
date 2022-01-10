defmodule Lurra.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do

    create index(:events, [:device_id, :type])
  end
end
