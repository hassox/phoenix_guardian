defmodule PhoenixGuardian.TokenController do
  use PhoenixGuardian.Web, :controller
  use Guardian.Phoenix.Controller

  alias PhoenixGuardian.GuardianToken
  alias Guardian.Plug.EnsureAuthenticated
  alias Guardian.Plug.EnsurePermissions

  plug EnsureAuthenticated, handler: __MODULE__, aud: "token"
  plug EnsurePermissions, [handler: __MODULE__, default: ~w(read_token)] when action in [:index]
  plug EnsurePermissions, [handler: __MODULE__, default: ~w(revoke_token)] when action in [:delete]

  def index(conn, _params, current_user, {:ok, %{"jti" => jti}}) do
    render conn,
           "index.html",
           current_user: current_user,
           tokens: GuardianToken.for_user(current_user),
           current_jti: jti
  end

  def delete(conn, %{"id" => jti}, current_user, _claims) do
    case Repo.get(GuardianToken, jti) do
      nil -> could_not_delete(conn)
      token ->
        case Repo.delete(token) do
          {:ok, _} ->
            {:ok, sub} = PhoenixGuardian.GuardianSerializer.for_token(current_user)
            if sub == token.sub do
              conn
              |> put_flash(:info, "Done")
              |> redirect(to: token_path(conn, :index))
            else
              could_not_delete(conn)
            end
          {:error, _} -> could_not_delete(conn)
        end
    end
  end

  defp could_not_delete(conn) do
    conn
    |> put_flash(:error, "Could not delete")
    |> redirect(external: redirect_back(conn))
  end

  # The unauthenticated function is called because this controller has been
  # specified as the handler.
  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Authentication required")
    |> redirect(to: auth_path(conn, :login, :identity))
  end

  def unauthorized(conn, _params) do
    conn
    |> put_flash(:error, "Unauthorized")
    |> redirect(external: redirect_back(conn))
  end
end
