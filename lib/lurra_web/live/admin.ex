defmodule LurraWeb.Admin do
  use Surface.LiveView

  alias Surface.Components.Link
  alias LurraWeb.Endpoint
  alias LurraWeb.Router.Helpers, as: Routes


  def render(assigns) do
    ~F"""
    <div class="container">
      <h1> Administration </h1>
      <ul>
        <li><Link label={"Sensors"} to={Routes.sensor_index_path(Endpoint, :index)} /></li>
        <li><Link label={"Observers"} to={Routes.observer_index_path(Endpoint, :index)} /></li>
        <li><Link label={"Observers location"} to={Routes.observer_location_index_path(Endpoint, :index)} /></li>
        <li><Link label={"Triggers"} to={Routes.trigger_index_path(Endpoint, :index)} /></li>
        <li><Link label={"Eco-oases"} to={Routes.eco_oasis_index_path(Endpoint, :index)} /></li>
        <li><Link label={"Last Events"} to={Routes.event_index_path(Endpoint, :index)} /></li>
        <li><Link label={"USB Buoy Manager"} to={ Routes.live_path(Endpoint, LurraWeb.BuoySerial)} /></li>
        <li><Link label={"Fast USB Buoy Manager"} to={ Routes.live_path(Endpoint, LurraWeb.BuoyFastSerial)} /></li>
        <li><Link label={"Bluetooth Buoy Manager"} to={ Routes.live_path(Endpoint, LurraWeb.BuoyBt)} /></li>
        <li><Link label={"Lab Logs"} to={Routes.lablog_index_path(Endpoint, :index)} /></li>
      </ul>
    </div>
    """
  end
end
