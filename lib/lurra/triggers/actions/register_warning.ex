defmodule Lurra.Triggers.Actions.RegisterWarning do
  @behaviour Lurra.Triggers.Action

  alias Lurra.Events

  def name(), do: "Register warning"
  def params(), do: []
  def to_human(_data), do: "Register warning"
  def run(_action, _rule, _payload, trigger) do
    Events.create_warning(%{date: :erlang.system_time(:millisecond), device_id: trigger.device_id, sensor_type: trigger.sensor_type, description: trigger.name})
    :ok
  end
end
