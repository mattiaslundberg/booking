defmodule BookingWeb.UpdateBookingTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, User, Permission}

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

    {:ok, bookable} =
      Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, %{
        context: %{user_id: user.id}
      })

    %{
      bookable: bookable,
      location: location,
      permission: permission,
      user: user,
      conn: build_conn()
    }
  end

  test "update successful", %{bookable: bookable, user: user} do
    now = DateTime.utc_now()

    {:ok, booking} =
      Booking.Booking.create(
        nil,
        %{bookable_id: bookable.id, label: "First", start: now, end: now},
        %{context: %{user_id: user.id}}
      )

    query = """
    mutation {
      updateBooking(
        id: #{booking.id}
        bookableId: #{bookable.id}
        label:"From graph"
        start:"#{now}"
        end:"#{now}"
      ) {
        label id
      }
    }
    """

    assert {:ok, %{data: %{"updateBooking" => %{"label" => "From graph"}}}} =
             Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end
end
