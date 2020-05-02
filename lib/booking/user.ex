defmodule Booking.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Booking.Repo

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    many_to_many :locations, Booking.Location, join_through: "permissions"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> hash_password()
    |> validate_required([:name, :email])
  end

  def validate_password(email, cleartext) do
    __MODULE__ |> Repo.get_by(email: email) |> check_hash(cleartext)
  end

  defp check_hash(%__MODULE__{password: password}, cleartext) do
    {salt, expected_hash} =
      password
      |> Base.decode64!()
      |> String.split_at(16)

    new_hash = :crypto.hash(:sha3_512, salt <> cleartext)

    new_hash == expected_hash
  end

  defp check_hash(_, cleartext) do
    salt = :crypto.strong_rand_bytes(16)
    :crypto.hash(:sha3_512, salt <> cleartext)
    false
  end

  defp hash_password(cs = %{changes: %{password: password}}) do
    salt = :crypto.strong_rand_bytes(16)
    hashed = :crypto.hash(:sha3_512, salt <> password)

    stored = (salt <> hashed) |> Base.encode64()
    %{cs | changes: %{cs.changes | password: stored}}
  end

  defp hash_password(cs), do: cs
end
