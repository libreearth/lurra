defmodule Lurra.Triggers.Rules.GreaterThan do
  @behaviour Lurra.Triggers.Rule

  def name(), do: "Greater than"
  def params(), do: ["limit_value"]
  def to_human(data), do: "Greater than #{data["limit_value"]}"
  def check_rule(rule, payload), do: parse(payload) > limit_value(rule)

  defp limit_value(%{"limit_value" => limit}) when is_integer(limit), do: limit
  defp limit_value(%{"limit_value" => limit}) when is_float(limit), do: limit
  defp limit_value(%{"limit_value" => limit}) when is_binary(limit) do
    case Float.parse(limit) do
      {value, _rest} -> value
      :error -> 0.0
    end
  end

  defp parse(limit) when is_integer(limit), do: limit
  defp parse(limit) when is_float(limit), do: limit
  defp parse(limit) when is_binary(limit) do
    case Float.parse(limit) do
      {value, _rest} -> value
      :error -> 0.0
    end
  end
end
