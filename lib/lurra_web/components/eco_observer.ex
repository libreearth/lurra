defmodule LurraWeb.Components.EcoObserver do
  @moduledoc """
  This component represents a EcoObserver (Box with sensors) and
  presents the last readings into the screen
  """
  use Surface.Component

  alias Surface.Components.Link
  alias LurraWeb.Router.Helpers, as: Routes
  alias Surface.Components.Form.Checkbox

  prop observer, :struct, required: true
  prop readings, :map, required: true
  prop show_checks, :boolean, required: true
  prop sensors_checked, :list, required: false, default: []
  prop can_see_warnings, :boolean, required: true
  prop warnings, :list, required: false, default: []

  def render(assigns) do
    ~F"""
    <div class="observer">
      <div class="header" phx-click="show_warnings" phx-value-id={@observer.device_id}>
        <h2>{@observer.name}</h2>
        {#if @can_see_warnings and not Enum.empty?(@warnings)}
          <div class="warning"><i class="fa fa-bell"></i><div class="alarm-count">{length(@warnings)}</div></div>
        {/if}
      </div>
      <ul>
      {#for sensor <- @observer.sensors}
        <li>
          {#if @readings[sensor.sensor_type]}
            {#if @show_checks}
              <Checkbox
                field={"sensor-#{@observer.id}-#{sensor.sensor_type}"}
                value={Enum.member?(@sensors_checked, "sensor-#{@observer.id}-#{sensor.sensor_type}")}
                hidden_input={false}
                />
            {/if}
            <strong>{sensor.name}:</strong> {format(@readings[sensor.sensor_type], sensor.precision)}{sensor.unit}
          {#else}
            {#if @show_checks}
              <Checkbox
                field={"sensor-#{@observer.id}-#{sensor.sensor_type}"}
                value={Enum.member?(@sensors_checked, "sensor-#{@observer.id}-#{sensor.sensor_type}")}
                hidden_input={false}
                />
            {/if}
            <strong>{sensor.name}:</strong> has no readings yet
          {/if}
          <Link to={Routes.live_path(LurraWeb.Endpoint, LurraWeb.Graph, @observer.device_id, sensor.sensor_type)}><i class="fa fa-line-chart"/></Link>
        </li>
      {/for}
      </ul>
    </div>
    """
  end

  def format(input, _decimals) when is_binary(input) do
    input
  end

  def format(input, _decimals) when is_integer(input) do
    input
  end

  def format(input, nil) when is_float(input) do
    :erlang.float_to_binary(input, decimals: 2)
  end

  def format(input, decimals) when is_float(input) do
    :erlang.float_to_binary(input, decimals: decimals)
  end

end
