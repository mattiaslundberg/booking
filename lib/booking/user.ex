defmodule Booking.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Booking.Repo

  @moduledoc """
  Representation of user in the system
  """

  @hash_fun Application.get_env(:booking, :hash_fun)
  @salt_len 16
  @salt_separator "<|>"

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    many_to_many :locations, Booking.Location, join_through: "permissions"

    timestamps()
  end

  def create(_parent, args = %{location_id: location_id}, res) do
    Booking.Location.by_id(nil, %{id: location_id}, res) |> do_create(args)
  end

  defp do_create({:ok, location}, args) do
    Repo.transaction(fn ->
      {:ok, user} =
        %__MODULE__{} |> __MODULE__.changeset(%{args | location_id: location.id}) |> Repo.insert()

      {:ok, _permission} =
        %Booking.Permission{}
        |> Booking.Permission.changeset(%{location_id: location.id, user_id: user.id})
        |> Repo.insert()

      user
    end)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> hash_password()
    |> validate_required([:name, :email])
  end

  @spec get_validated_user(String.t(), String.t()) :: {boolean(), %__MODULE__{} | nil}
  def get_validated_user(email, cleartext) do
    __MODULE__ |> Repo.get_by(email: email) |> check_hash(cleartext)
  end

  @spec validate_password(String.t(), String.t()) :: boolean()
  def validate_password(email, cleartext) do
    {valid?, _user} = get_validated_user(email, cleartext)
    valid?
  end

  @spec check_hash(%__MODULE__{}, String.t()) :: {boolean(), %__MODULE__{} | nil}
  defp check_hash(user = %__MODULE__{password: password}, cleartext) do
    [salt, expected_hash] =
      password
      |> Base.decode64!()
      |> String.split(@salt_separator, parts: 2)

    new_hash = :crypto.hash(@hash_fun, salt <> cleartext)

    {new_hash == expected_hash, user}
  end

  defp check_hash(_, cleartext) do
    salt = :crypto.strong_rand_bytes(@salt_len)
    :crypto.hash(@hash_fun, salt <> cleartext)
    {false, nil}
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
