defmodule LurraWeb.Router do
  use LurraWeb, :router

  import LurraWeb.UserAuth

  import Surface.Catalogue.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LurraWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user

    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_admin do
    plug LurraWeb.RolePlug, role: "admin"
    plug LurraWeb.VerifiedPlug
  end

  scope "/", LurraWeb do
    pipe_through :browser

    get "/", PageController, :index

  end

  # Other scopes may use custom stacks.
   scope "/", LurraWeb do
     pipe_through :api

     post "/webhook", LurraWebhookController, :webhook
   end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/live_dashboard", metrics: LurraWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      surface_catalogue "/catalogue"
    end
  end

  ## Authentication routes

  scope "/", LurraWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LurraWeb do
    pipe_through [:browser, :require_authenticated_user, LurraWeb.VerifiedPlug]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update

    get "/data/:device_id/:sensor_type", DownloadDataController, :index

    live "/events", EventLive.Index, :index

    live "/dashboard", Dashboard
    live "/graph/:device_id/:sensor_type", Graph
  end

  scope "/", LurraWeb do
    pipe_through [:browser, :require_admin]

    live "/sensors", SensorLive.Index, :index
    live "/sensors/new", SensorLive.Index, :new
    live "/sensors/:id/edit", SensorLive.Index, :edit
    live "/sensors/:id", SensorLive.Show, :show
    live "/sensors/:id/show/edit", SensorLive.Show, :edit

    live "/observers", ObserverLive.Index, :index
    live "/observers/new", ObserverLive.Index, :new
    live "/observers/:id/edit", ObserverLive.Index, :edit

    live "/observers/:id", ObserverLive.Show, :show
    live "/observers/:id/show/edit", ObserverLive.Show, :edit

    live "/users", UserLive.Index, :index
    live "/users/:id/edit", UserLive.Index, :edit
  end

  scope "/", LurraWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/wait_confirmation", WaitConfirmationController, :index
  end
end
