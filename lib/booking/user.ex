defmodule Booking.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Booking.Repo

  @hash_fun :sha3_256
  @salt_len 16
  @salt_separator "<|>"

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

  @spec validate_password(String.t(), String.t()) :: boolean()
  def validate_password(email, cleartext) do
    __MODULE__ |> Repo.get_by(email: email) |> check_hash(cleartext)
  end

  @spec check_hash(%__MODULE__{}, String.t()) :: boolean()
  defp check_hash(%__MODULE__{password: password}, cleartext) do
    [salt, expected_hash] =
      password
      |> Base.decode64!()
      |> String.split(@salt_separator, parts: 2)

    new_hash = :crypto.hash(@hash_fun, salt <> cleartext)

    new_hash == expected_hash
  end

  defp check_hash(_, cleartext) do
    salt = :crypto.strong_rand_bytes(@salt_len)
    :crypto.hash(@hash_fun, salt <> cleartext)
    false
  end

  @spec hash_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp hash_password(cs = %{changes: %{password: password}}) do
    salt = :crypto.strong_rand_bytes(@salt_len)
    hashed = :crypto.hash(@hash_fun, salt <> password)

    stored = (salt <> @salt_separator <> hashed) |> Base.encode64()
    %{cs | changes: %{cs.changes | password: stored}}
  end

  defp hash_password(cs), do: cs
end
