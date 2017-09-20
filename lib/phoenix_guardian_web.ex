defmodule PhoenixGuardianWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use PhoenixGuardianWeb, :controller
      use PhoenixGuardianWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def admin_controller do
    quote do
      use Phoenix.Controller, namespace: PhoenixGuardianWeb.Admin
      use Guardian.Phoenix.Controller, key: :admin

      alias PhoenixGuardian.Repo
      alias Guardian.Plug.EnsureAuthenticated
      alias Guardian.Plug.EnsurePermissions

      import Ecto.Schema
      import Ecto.Query, only: [from: 1, from: 2]

      import PhoenixGuardianWeb.Router.Helpers
      import PhoenixGuardianWeb.Controller.Helpers
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: PhoenixGuardianWeb
      use Guardian.Phoenix.Controller

      alias PhoenixGuardian.Repo
      alias Guardian.Plug.EnsureAuthenticated
      alias Guardian.Plug.EnsurePermissions

      import Ecto.Schema
      import Ecto.Query, only: [from: 1, from: 2]

      import PhoenixGuardianWeb.Router.Helpers
      import PhoenixGuardianWeb.Controller.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/phoenix_guardian_web/templates", namespace: PhoenixGuardianWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import PhoenixGuardianWeb.Router.Helpers
      import PhoenixGuardianWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias PhoenixGuardian.Repo
      import Ecto.Schema
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
