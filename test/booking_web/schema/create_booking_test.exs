defmodule BookingWeb.CreateBookingTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

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
