defmodule PhoenixGuardian.SessionController do
  use PhoenixGuardian.Web, :controller

  alias PhoenixGuardian.User
  alias PhoenixGuardian.UserQuery

  plug :scrub_params, "user" when action in [:create]
  plug :action

  def new(conn, params) do
    changeset = User.login_changeset(%User{})
    render(conn, PhoenixGuardian.SessionView, "new.html", changeset: changeset)
  end

  def create(conn, params = %{}) do
    user = Repo.one(UserQuery.by_email(params["user"]["email"] || ""))
    if user do
      changeset = User.login_changeset(user, params["user"])
      if changeset.valid? do
        conn
        |> put_flash(:info, "Logged in.")
        |> Guardian.Plug.sign_in(user, :csrf, perms: %{ default: Guardian.Permissions.max })
        |> redirect(to: user_path(conn, :index))
      else
        render(conn, "new.html", changeset: changeset)
      end
    else
      changeset = User.login_changeset(%User{}) |> Ecto.Changeset.add_error(:login, "not found")
      render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

  def unauthenticated_api(conn, _params) do
    the_conn = put_status(conn, 401)
    case Guardian.Plug.claims(conn) do
      { :error, :no_session } -> json(the_conn, %{ error: "Login required" })
      { :error, reason } -> json(the_conn, %{ error: reason })
      _ -> json(the_conn, %{ error: "Login required" })
    end
  end

  def forbidden_api(conn, _) do
    conn
    |> put_status(403)
    |> json(%{ error: :forbidden })
  end
end
