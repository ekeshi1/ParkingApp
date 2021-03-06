defmodule ParkingWeb.Router do
  use ParkingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser_auth do
    plug Parking.AuthPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", ParkingWeb do
    pipe_through :browser

  end





  scope "/", ParkingWeb do
    pipe_through [:browser, :browser_auth]
    # Stuff that anybody can access
    get "/", PageController, :index
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/users", UserController, only: [:new, :create]
    resources "/bookings", BookingController
    get "booking/extend-page", BookingController, :extend_page
    post "booking/extend", BookingController, :extend

    get "/search", Parking_placeController ,:index
    get "/search/some", Parking_placeController ,:create
    post "/search/some", Parking_placeController ,:create
    get "/search/data", Parking_placeController ,:new
    resources "/invoices", InvoiceController

  end

  scope "/", ParkingWeb do
    pipe_through [:browser, :browser_auth, :ensure_auth]

    # Stuff only logged in users should access

  end

  # Other scopes may use custom stacks.
  # scope "/api", ParkingWeb do
  #   pipe_through :api
  # end

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
      live_dashboard "/dashboard", metrics: ParkingWeb.Telemetry
    end
  end
end
