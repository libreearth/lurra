defmodule Lurra.Triggers.Actions.SendEmail do
  @behaviour Lurra.Triggers.Action

  import Swoosh.Email

  def name(), do: "Send email"
  def params(), do: ["email"]
  def to_human(data), do: "Send email to #{data["email"]}"
  def run(action, _rule, _payload, trigger) do
    email = email(trigger, action)
    IO.puts "MAAAAAAAAAAAAAAAAILLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL"
    Lurra.Mailer.deliver(email) |> IO.inspect
    :ok
  end

  defp email(%{name: name}, %{"email" => email}) do
    new()
    |> from({"Eco Oasis Lurra Mail", "noreply@theweathermakers.nl"})
    |> to({"Gabriel Bellido Perez", email})
    |> subject(name)
    |> text_body(name)
  end
end
