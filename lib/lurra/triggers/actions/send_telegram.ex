defmodule Lurra.Triggers.Actions.SendTelegram do
  @behaviour Lurra.Triggers.Action
  @chat_id Application.get_env(:lurra, :tg_chat_id)

  def name(), do: "Send Telegram"
  def params(), do: []
  def to_human(data), do: "Send email to #{data["email"]}"
  def run(_action, _rule, _payload, trigger, %{last_true: last_true}, time) when last_true == time  do
    Nadia.send_message(@chat_id, trigger.name)
    :ok
  end
  def run(_action, _rule, _payload, _trigger, _status, _time), do: :ok
end
