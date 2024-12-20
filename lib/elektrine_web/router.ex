defmodule ElektrineWeb.Router do
  use ElektrineWeb, :router

  import ElektrineWeb.Plugs.AuthPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElektrineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ElektrineWeb.Plugs.RateLimiter
    plug Guardian.Plug.Pipeline,
      module: Elektrine.Accounts.Guardian,
      error_handler: ElektrineWeb.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug ElektrineWeb.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ElektrineWeb.Plugs.RateLimiter
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: Elektrine.Accounts.Guardian,
      error_handler: ElektrineWeb.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  scope "/", ElektrineWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/register", AuthController, :register
    post "/register", AuthController, :register
    get "/login", AuthController, :login
    post "/login", AuthController, :login
    delete "/logout", AuthController, :logout
    get "/reset-password", PasswordResetController, :new
    post "/reset-password", PasswordResetController, :create
    get "/reset-password/:token", PasswordResetController, :edit
    put "/reset-password/:token", PasswordResetController, :update
  end

  scope "/api", ElektrineWeb do
    pipe_through [:api]

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api", ElektrineWeb do
    pipe_through [:api, :auth]

    # Protected routes go here
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElektrineWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:elektrine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ElektrineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", ElektrineWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/settings", UserSettingsController, :edit
    put "/settings/update_username", UserSettingsController, :update_username
    put "/settings/update_password", UserSettingsController, :update_password
    put "/settings/update_recovery_email", UserSettingsController, :update_recovery_email
    put "/settings/update_avatar", UserSettingsController, :update_avatar
  end
end
