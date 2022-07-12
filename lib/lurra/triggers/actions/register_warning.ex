defmodule Lurra.Triggers.Actions.RegisterWarning do
  @behaviour Lurra.Triggers.Action

  alias Lurra.Events

  def name(), do: "Register warning"
  def params(), do: []
  def to_human(_data), do: "Register warning"
  def run(_action, _rule, _payload, trigger, %{last_true: last_true}, time) when last_true == time do
    Events.create_warning(%{date: time, device_id: trigger.device_id, sensor_type: trigger.sensor_type, description: trigger.name})
    :ok
  end
  def run(_action, _rule, _payload, _trigger, _status, _time), do: :ok
end
