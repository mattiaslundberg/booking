defmodule BookingWeb.CreateBookingTest do
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

    {:ok, other_bookable} =
      Bookable.create(nil, %{location_id: location.id, name: "Other"}, %{
        context: %{user_id: user.id}
      })

    %{
      bookable: bookable,
      other_bookable: other_bookable,
      location: location,
      permission: permission,
      user: user,
      conn: build_conn()
    }
  end

  test "missing bookable", %{user: user} do
    now = DateTime.utc_now()

    query = """
    mutation {
      createBooking(label:"From graph" start:"#{now}" end:"#{now}") {
        label id
      }
    }
    """

    assert {:ok,
            %{
              errors: [
                %{
                  message: "In argument \"bookableId\": Expected type \"Int!\", found null."
                }
              ]
            }} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end

  test "invalid date", %{user: user, bookable: bookable} do
    now = DateTime.utc_now()

    query = """
    mutation {
      createBooking(bookableId: #{bookable.id}, label:"From graph", start:"notdate" end:"#{now}") {
        label id
      }
    }
    """

    assert {:ok,
            %{
              errors: [
                %{
                  message: "Argument \"start\" has invalid value \"notdate\"."
                }
              ]
            }} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end

  test "end before start", %{user: user, bookable: bookable} do
    start = DateTime.utc_now()
    stop = DateTime.add(start, -1000)

    query = """
    mutation {
      createBooking(bookableId: #{bookable.id}, label:"From graph", start:"#{start}" end:"#{stop}") {
        label id
      }
    }
    """

    assert {:ok,
            %{
              errors: [
                %{
                  message: ~S|end: Expected "start" to be before "end".|
                }
              ]
            }} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end

  test "create successful", %{user: user, bookable: bookable} do
    now = DateTime.utc_now()

    query = """
    mutation {
      createBooking(bookableId: #{bookable.id}, label:"From graph", start:"#{now}" end:"#{now}") {
        label id
      }
    }
    """

    assert {:ok, %{data: %{"createBooking" => %{"label" => "From graph"}}}} =
             Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end
end
