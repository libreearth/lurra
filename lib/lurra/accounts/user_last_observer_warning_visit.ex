defmodule Lurra.Account.UserLastObserverWarningVisit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lurra.Account.UserLastObserverWarningVisit

  schema "user_last_observer_warning_visits" do
    belongs_to :user, Lurra.Accounts.User
    field :timestamp, :integer
    field :device_id, :string

    timestamps()
  end

  def changeset(%UserLastObserverWarningVisit{} = user_last_observer_warning_visit, attrs) do
    user_last_observer_warning_visit
    |> cast(attrs, [:timestamp, :device_id])
    |> validate_required([:timestamp, :device_id])
  end
end
