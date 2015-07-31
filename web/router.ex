defmodule PhoenixGuardian.Router do
  use PhoenixGuardian.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyAuthorization, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", PhoenixGuardian do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/", PageController, :index

    get "/login", SessionController, :new, as: :login
    post "/login", SessionController, :create, as: :login
    delete "/logout", SessionController, :delete, as: :logout
    get "/logout", SessionController, :delete, as: :logout

    resources "/users", UserController
  end

  scope "/api/v1", PhoenixGuardian.Api.V1 do
    pipe_through [:api]

    resources "/users", UserController
  end


  # Other scopes may use custom stacks.
  # scope "/api", PhoenixGuardian do
  #   pipe_through :api
  # end
end
