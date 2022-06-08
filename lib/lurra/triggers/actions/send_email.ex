defmodule Lurra.Triggers.Actions.SendEmail do
  @behaviour Lurra.Triggers.Action

  import Swoosh.Email

  def name(), do: "Send email"
  def params(), do: ["name", "email"]
  def to_human(data), do: "Send email to #{data["email"]}"
  def run(action, _rule, _payload, trigger) do
    email = email(trigger, action)
    Lurra.Mailer.deliver(email)
    :ok
  end

  defp email(%{name: name}, %{"email" => email, "name" => username}) do
    new()
    |> from({"Lurra Eco Oasis", "gabi@theweathermakers.nl"})
    |> to({username, email})
    |> subject(name)
    |> text_body(name)
  end
end
