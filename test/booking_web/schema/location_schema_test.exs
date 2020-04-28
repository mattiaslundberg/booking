defmodule BookingWeb.LocationSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "non existing" do
    query = "{ location(id: 999) { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Booking.Schema)

    assert data == %{"location" => nil}
  end

  test "with bookables" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ location(id: #{location.id}) { id bookables { id } } }"
    {:ok, %{data: data}} = Absinthe.run(query, Booking.Schema)

    assert data == %{
             "location" => %{
               "id" => "#{location.id}",
               "bookables" => [%{"id" => "#{bookable.id}"}]
             }
           }
  end
end
