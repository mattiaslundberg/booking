defmodule BookingWeb.UpdateBookingTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "update successful" do
    now = DateTime.utc_now()
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    {:ok, bookable} = Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, nil)

    {:ok, booking} =
      Booking.Booking.create(
        nil,
        %{bookable_id: bookable.id, label: "First", start: now, end: now},
        nil
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
             Absinthe.run(query, Booking.Schema)
  end
end
