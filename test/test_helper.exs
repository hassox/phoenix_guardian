defmodule PhoenixGuardian.TestHelper do
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def conn_with_fetched_session(the_conn) do
    put_in(the_conn.secret_key_base, @secret)
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session
  end

  def sign_in(conn, resource, perms \\ Guardian.Permissions.max) do
    conn
    |> conn_with_fetched_session
    |> Guardian.Plug.sign_in(resource, :token, perms: %{default: perms})
    |> Guardian.Plug.VerifySession.call([])
  end
end

ExUnit.start

# Create the database, run migrations, and start the test transaction.
Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(PhoenixGuardian.Repo)
