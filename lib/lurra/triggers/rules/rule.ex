defmodule Lurra.Triggers.Rule do
  def all, do: [Lurra.Triggers.Rules.GreaterThan, Lurra.Triggers.Rules.LowerThan, Lurra.Triggers.Rules.InBetween, Lurra.Triggers.Rules.InactiveMoreThan]
  def time_triggers, do: [Lurra.Triggers.Rules.InactiveMoreThan]

  def to_human(nil), do: "None"
  def to_human(data) when is_binary(data) do
    case data |> Jason.decode() do
      {:ok, decoded} -> to_human(decoded)
      {:error, _} -> "None"
    end
  end
  def to_human(data) when is_map(data), do: apply(String.to_atom(data["module"]), :to_human, [data])

  def check_rule(nil,_), do: false
  def check_rule(rule, payload) when is_binary(rule) do
    case rule |> Jason.decode() do
      {:ok, decoded} -> check_rule(decoded, payload)
      {:error, _} -> false
    end
  end
  def check_rule(rule, payload) when is_map(rule), do: apply(String.to_atom(rule["module"]), :check_rule, [rule, payload])

  def is_time_rule(rule) do
    case rule |> Jason.decode() do
      {:ok, decoded} -> Enum.member?(time_triggers(), String.to_atom(decoded["module"]))
      {:error, _} -> false
    end
  end

  def check_time_rule(nil,_current_timestamp, _latest_timestamp), do: false
  def check_time_rule(rule, current_timestamp, latest_timestamp) when is_binary(rule) do
    case rule |> Jason.decode() do
      {:ok, decoded} -> check_time_rule(decoded, current_timestamp, latest_timestamp)
      {:error, _} -> false
    end
  end
  def check_time_rule(rule, current_timestamp, latest_timestamp) when is_map(rule), do: apply(String.to_atom(rule["module"]), :check_time_rule, [rule, current_timestamp, latest_timestamp])

  @callback name()::binary
  @callback params()::[binary]
  @callback to_human(data::map)::binary
  @callback check_rule(rule::map, payload::any)::boolean
end
