defmodule PhoenixPlaywrithingWeb.Router do
  use PhoenixPlaywrithingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixPlaywrithingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixPlaywrithingWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/qualifier", QualifierLive
    live "/contact-preference", ContactPreferenceLive
    live "/offer", OfferLive
    live "/contracts", ContractsLive
  end

  if Application.compile_env(:phoenix_playwrithing, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PhoenixPlaywrithingWeb.Telemetry
    end
  end
end
