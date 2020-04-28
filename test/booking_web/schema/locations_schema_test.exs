defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, Schema}

  test "empty" do
    query = "{ locations { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{"locations" => []}
  end

  test "non empty without bookables" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id bookables { id } } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data ==
             %{"locations" => [%{"id" => "#{location.id}", "bookables" => []}]}
  end

  test "with bookables" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ locations { id bookables { id } } }"

    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "locations" => [
               %{"id" => "#{location.id}", "bookables" => [%{"id" => "#{bookable.id}"}]}
             ]
           }
  end

  test "http non empty with id and name", %{conn: conn} do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id name } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"name" => "First", "id" => "#{location.id}"}]}
           }
  end
end
