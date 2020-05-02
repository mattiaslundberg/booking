defmodule Booking.UserTest do
  use Booking.DataCase, async: false
  alias Booking.User
  alias Booking.Repo

  test "set password" do
    changeset =
      %User{} |> User.changeset(%{name: "First", email: "first@example.com", password: "secret"})

    assert changeset.valid?
    assert !is_nil(changeset.changes.password)
    assert changeset.changes.password != "secret"
  end

  test "validate password" do
    user =
      %User{}
      |> User.changeset(%{name: "First", email: "first@example.com", password: "secret"})
      |> Repo.insert!()

    assert User.validate_password(user.email, "secret")
    refute User.validate_password(user.email, "invalid")
    refute User.validate_password(user.email, "")
    refute User.validate_password("unknown@example.com", "secret")
  end
end
