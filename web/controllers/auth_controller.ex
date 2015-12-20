defmodule PhoenixGuardian.AuthController do
  @moduledoc """
  Handles the Überauth integration.
  This controller implements the request and callback phases for all providers.
  The actual creation and lookup of users/authorizations is handled by UserFromAuth
  """
  use PhoenixGuardian.Web, :controller
  use Guardian.Phoenix.Controller

  alias PhoenixGuardian.UserFromAuth
  alias Ueberauth.Strategy.Helpers

  plug Ueberauth

  def login(conn, params, current_user, _claims) do
    render conn, "login.html", current_user: current_user, current_auths: auths(current_user)
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, current_user, _claims) do
    conn
    |> put_flash(:error, hd(fails.errors).message)
    |> render("login.html", current_user: current_user, current_auths: auths(current_user))
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :token)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, "Could not authenticate")
        |> render("login.html", current_user: current_user, current_auths: auths(current_user))
    end
  end

  def logout(conn, _params, current_user, _claims) do
    if current_user do
      conn
      |> Guardian.Plug.sign_out
      |> put_flash(:info, "Signed out")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:info, "Not logged in")
      |> redirect(to: "/")
    end
  end

  defp auths(nil), do: []
  defp auths(%PhoenixGuardian.User{} = user) do
    Ecto.Model.assoc(user, :authorizations)
      |> Repo.all
      |> Enum.map(&(&1.provider))
  end
end
