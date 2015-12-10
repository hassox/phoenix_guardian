defmodule PhoenixGuardian.AuthController do
  use PhoenixGuardian.Web, :controller
  use Guardian.Phoenix.Controller

  alias PhoenixGuardian.UserFromAuth

  require Ueberauth

  Ueberauth.plug("/auth")

  def request(conn, _params, _current_user, _claims) do
    conn
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, _current_user, _claims) do
    conn
    |> put_flash(:error, "Could not authenticate")
    |> redirect(to: "/")
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
        |> put_flash(:error, "Could not authenticate #{reason}")
        |> Guardian.Plug.sign_out
        |> redirect(to: "/")
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
end
