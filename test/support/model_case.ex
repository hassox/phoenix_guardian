defmodule PhoenixGuardian.ModelCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias PhoenixGuardian.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]
      import PhoenixGuardian.ModelCase
    end
  end

  setup tags do
    # Explicitly get a connection before each test
    # By default the test is wrapped in a transaction
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PhoenixGuardian.Repo)

    # The :shared mode allows a process to share 
    # its connection with any other process automatically
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PhoenixGuardian.Repo, {:shared, self()})
    end
    :ok
  end

  @doc """
  Helper for returning list of errors in model when passed certain data.

  ## Examples

  Given a User model that lists `:name` as a required field and validates
  `:password` to be safe, it would return:

      iex> errors_on(%User{}, %{password: "password"})
      [password: "is unsafe", name: "is blank"]

  You could then write your assertion like:

      assert {:password, "is unsafe"} in errors_on(%User{}, %{password: "password"})

  You can also insert the changeset manually and retrieve the errors
  field directly:

      iex> changeset = User.changeset(%User{}, password: "password")
      iex> {:password, "is unsafe"} in changeset.errors
      true
  """
  def errors_on(model, data) do
    model.__struct__.changeset(model, data).errors
  end
end
