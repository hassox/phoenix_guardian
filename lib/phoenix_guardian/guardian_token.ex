defmodule PhoenixGuardian.GuardianToken do
  alias PhoenixGuardian.Repo
  import Ecto.Query, only: [from: 2]
  use Ecto.Schema

  @primary_key {:jti, :string, []}
  @derive {Phoenix.Param, key: :jti}
  schema "guardian_tokens" do
    field :aud, :string
    field :iss, :string
    field :sub, :string
    field :exp, :integer
    field :jwt, :string
    field :claims, :map

    timestamps()
  end

  def for_user(user) do
    case PhoenixGuardianWeb.GuardianSerializer.for_token(user) do
      {:ok, aud} ->
        (from t in __MODULE__, where: t.sub == ^aud)
          |> Repo.all
      _ -> []
    end
  end
end
