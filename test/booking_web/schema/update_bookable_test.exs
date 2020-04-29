defmodule BookingWeb.UpdateBookableTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "update successful" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    {:ok, bookable} = Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, nil)

    query = """
    mutation {
      updateBookable(id: #{bookable.id} locationId: #{location.id} name:"From graph") {
        name id
      }
    }
    """

    assert {:ok, %{data: %{"updateBookable" => %{"name" => "From graph"}}}} =
             Absinthe.run(query, Booking.Schema)
  end
end
