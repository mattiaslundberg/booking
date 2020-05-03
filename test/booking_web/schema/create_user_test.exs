defmodule BookingWeb.CreateUserTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, User, Permission}

  setup do
    user =
      %User{}
      |> User.changeset(%{name: "User", email: "user@example.com", password: "secret"})
      |> Repo.insert!()

    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    permission =
      %Permission{}
      |> Permission.changeset(%{location_id: location.id, user_id: user.id})
      |> Repo.insert!()

    %{
      location: location,
      permission: permission,
      user: user,
      conn: build_conn()
    }
  end

  test "create user with correct permission", %{user: user, location: location} do
    query = """
    mutation {
      createUser(name: "From graph" password: "secret" email: "graph@example.com" locationId: #{
      location.id
    }) {
        id name locations { id }
      }
    }
    """

    location_id = Integer.to_string(location.id)

    assert {:ok,
            %{
              data: %{
                "createUser" => %{
                  "name" => "From graph",
                  "locations" => [%{"id" => ^location_id}]
                }
              }
            }} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end
end
