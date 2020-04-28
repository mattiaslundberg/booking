defmodule BookingWeb.LocationSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "non existing", %{conn: conn} do
    query = "{ location(id: 999) { id } }"

    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{"data" => %{"location" => nil}}
  end

  test "with bookables", %{conn: conn} do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ location(id: #{location.id}) { id bookables { id } } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{
               "location" => %{
                 "id" => "#{location.id}",
                 "bookables" => [%{"id" => "#{bookable.id}"}]
               }
             }
           }
  end
end
