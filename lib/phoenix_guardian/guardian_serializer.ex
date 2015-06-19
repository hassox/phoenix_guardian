defmodule PhoenixGuardian.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias PhoenixGuardian.Repo
  alias PhoenixGuardian.User

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id) do
    IO.puts("THE ID is #{inspect(id)}")
    IO.inspect(String.to_integer(id))
    { :ok, Repo.get(User, String.to_integer(id)) }
  end

  def from_token(thing) do
    IO.puts("HERE WE ARE #{inspect(thing)}")
    { :error, "Unknown resource type" }
  end
end
