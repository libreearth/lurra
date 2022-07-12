defmodule Lurra.Triggers.Action do
  alias Lurra.Triggers.Trigger

  def all do
    [Lurra.Triggers.Actions.RegisterWarning, Lurra.Triggers.Actions.SendEmail, Lurra.Triggers.Actions.SendTelegram]
  end

  def to_human(data) when is_binary(data) do
    case data |> Jason.decode() do
      {:ok, decoded} -> to_human(decoded)
      {:error, _} -> "None"
    end
  end
  def to_human(data) when is_list(data), do: Enum.map(data,& to_human/1) |> Enum.join(", ")
  def to_human(data) when is_map(data), do: apply(String.to_atom(data["module"]), :to_human, [data])

  def run(%Trigger{} = trigger, %{} = status, time, payload) do
    case Jason.decode(trigger.rule) do
      {:ok, rule} ->
        case Jason.decode(trigger.actions) do
          {:ok, actions} ->
              run(actions, rule, payload, trigger, status, time)
          _ ->
            nil
        end
      {:error} ->
        nil
    end
  end

  def run(actions, rule, payload, %Trigger{} = trigger, %{} = status, time) when is_list(actions) and is_map(rule) do
    Enum.each(actions, fn action -> apply(String.to_atom(action["module"]), :run, [action, rule, payload, trigger, status, time]) end)
  end

  @callback name()::binary
  @callback params()::[binary]
  @callback run(action:: map, rule::map, payload::any, trigger::map, status::map, time::number()):: :ok
end
