defmodule BookingWeb.CreateBookingTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "missing bookable" do
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
            }} = Absinthe.run(query, Booking.Schema)
  end

  test "invalid date" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    {:ok, bookable} = Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, nil)

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
            }} = Absinthe.run(query, Booking.Schema)
  end

  test "end before start" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    {:ok, bookable} = Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, nil)

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
            }} = Absinthe.run(query, Booking.Schema)
  end

  test "create successful" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    {:ok, bookable} = Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, nil)

    now = DateTime.utc_now()

    query = """
    mutation {
      createBooking(bookableId: #{bookable.id}, label:"From graph", start:"#{now}" end:"#{now}") {
        label id
      }
    }
    """

    assert {:ok, %{data: %{"createBooking" => %{"label" => "From graph"}}}} =
             Absinthe.run(query, Booking.Schema)
  end
end