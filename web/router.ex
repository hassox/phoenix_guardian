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

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", PhoenixGuardian do
    pipe_through [:browser, :browser_auth] # Use the default browser stack

    get "/", PageController, :index
    get "/maybe-public", PageController, :maybe_public
    get "/login", PageController, :login
    delete "/logout", AuthController, :logout

    scope "/auth" do
      get "/:identity", AuthController, :login
      get "/:identity/callback", AuthController, :callback
      post "/:identity/callback", AuthController, :callback
    end

    resources "/users", UserController
    resources "/authorizations", AuthorizationController

    get "/private", PrivatePageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", PhoenixGuardian do
    pipe_through [:api, :api_auth]
  end
end
