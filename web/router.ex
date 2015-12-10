defmodule PhoenixGuardian.Router do
  use PhoenixGuardian.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixGuardian do
    pipe_through [:browser, :browser_auth] # Use the default browser stack

    get "/", PageController, :index

    scope "/auth" do
      get "/:identity", AuthController, :request
      get "/:identity/callback", AuthController, :callback
      post "/:identity/callback", AuthController, :callback
    end

    get "/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixGuardian do
  #   pipe_through :api
  # end
end
