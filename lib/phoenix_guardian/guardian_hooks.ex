defmodule PhoenixGuardian.GuardianHooks do
  use Guardian.Hooks

  def before_mint(resource, type, claims) do
    IO.puts("GOING TO MINT: #{inspect(resource)} WITH TYPE #{inspect(type)} AND CLAIMS #{inspect(claims)}")
    { :ok, { resource, type, claims } }
  end

  def after_sign_in(conn, location) do
    user = Guardian.Plug.current_resource(conn, location)
    IO.puts("SIGNED INTO LOCATION WITH: #{user.email}")
    conn
  end

  def before_sign_out(conn, nil), do: before_sign_out(conn, :default)

  def before_sign_out(conn, :all) do
    IO.puts("SIGNING OUT ALL THE PEOPLE")
    conn
  end

  def before_sign_out(conn, location) do
    user = Guardian.Plug.current_resource(conn, location)
    IO.puts("SIGNING OUT: #{user.email}")
    conn
  end
end
