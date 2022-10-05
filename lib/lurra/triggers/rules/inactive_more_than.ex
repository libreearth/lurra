defmodule Lurra.Triggers.Rules.InactiveMoreThan do
  @behaviour Lurra.Triggers.Rule

  def name(), do: "Inactive more than"
  def params(), do: ["minutes"]
  def to_human(data), do: "Inactive more than #{data["minutes"]} minutes"
  def check_rule(_rule, _payload), do: false
  def check_time_rule(rule, now_timestamp, last_timestamp) do
    minutes(rule)*60*1000 < now_timestamp - last_timestamp
  end

  defp minutes(%{"minutes" => limit}) when is_integer(limit), do: limit
  defp minutes(%{"minutes" => limit}) when is_float(limit), do: limit
  defp minutes(%{"minutes" => limit}) when is_binary(limit) do
    case Float.parse(limit) do
      {value, _rest} -> value
      :error -> 0.0
    end
  end
end
