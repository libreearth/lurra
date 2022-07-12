defmodule Lurra.Triggers.Actions.SendEmail do
  @behaviour Lurra.Triggers.Action

  import Swoosh.Email

  def name(), do: "Send email"
  def params(), do: ["name", "email", "minutes_between_mails"]
  def to_human(data), do: "Send email to #{data["email"]}"
  def run(action, _rule, _payload, trigger, %{last_true: last_true}, time) when last_true == time  do
    minutes_between_mails = get_minutes_between_mails(action)
    last_sent = get_last_mail_sent(trigger.id, action)
    if can_send_email(minutes_between_mails, last_sent, time) do
      email = email(trigger, action)
      Lurra.Mailer.deliver(email)
      set_last_mail_sent(trigger.id, action, time)
    end
    :ok
  end
  def run(_action, _rule, _payload, _trigger, _status, _time), do: :ok

  defp email(%{name: name}, %{"email" => email, "name" => username}) do
    new()
    |> from({"Lurra Eco Oasis", "gabi@theweathermakers.nl"})
    |> to({username, email})
    |> subject(name)
    |> text_body(name)
  end

  defp get_minutes_between_mails(%{"minutes_between_mails" => mb_mails_text}) when is_binary(mb_mails_text) do
    case Integer.parse(mb_mails_text) do
      {res, _} -> res
      :error -> 0
    end
  end
  defp get_minutes_between_mails(_), do: 0

  defp can_send_email(0, _last_sent, _time), do: true
  defp can_send_email(_minutes_between_mails, nil, _time), do: true
  defp can_send_email(minutes_between_mails, last_sent, time) do
    time = time - last_sent
    minutes_between_mails*60*1000 < time
  end

  defp get_last_mail_sent(trigger_id, action) do
    id = {trigger_id, action, :last_mail}
    case :ets.lookup(:actions, id) do
      [] -> nil
      [{^id, time}] -> time
    end
  end

  defp set_last_mail_sent(trigger_id, action, time) do
    id = {trigger_id, action, :last_mail}
    :ets.insert(:actions, {id, time})
  end
end
