defmodule Lurra.Triggers.Rules.InBetween do
  @behaviour Lurra.Triggers.Rule

  def name(), do: "In between"
  def params(), do: ["min_value", "max_value"]
  def to_human(data), do: "Between #{data["min_value"]} and #{data["max_value"]}"
  def check_rule(rule, payload), do: payload >= min_value(rule) and payload <= max_value(rule)

  defp min_value(%{"min_value" => limit}) when is_integer(limit), do: limit
  defp min_value(%{"min_value" => limit}) when is_float(limit), do: limit
  defp min_value(%{"min_value" => limit}) when is_binary(limit) do
    case Float.parse(limit) do
      {value, _rest} -> value
      :error -> 0.0
    end
  end

  defp max_value(%{"max_value" => limit}) when is_integer(limit), do: limit
  defp max_value(%{"max_value" => limit}) when is_float(limit), do: limit
  defp max_value(%{"max_value" => limit}) when is_binary(limit) do
    case Float.parse(limit) do
      {value, _rest} -> value
      :error -> 0.0
    end
  end
end
