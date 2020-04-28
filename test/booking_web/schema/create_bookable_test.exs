defmodule BookingWeb.CreateBookableTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "create successful" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    query = """
    mutation {
      createBookable(locationId: #{location.id}, name:"From graph") {
        name id
      }
    }
    """

    {:ok, %{data: %{"createBookable" => bookable}}} = Absinthe.run(query, Booking.Schema)

    assert Map.get(bookable, "name") == "From graph"

    db_bookable = Bookable |> Repo.get(Map.get(bookable, "id"))
    assert db_bookable.name == "From graph"
  end
end
