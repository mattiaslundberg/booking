defmodule Booking.Schema do
  use Absinthe.Schema
  alias Booking.{Location, Bookable, Repo, Booking}
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :location do
    field :id, :id
    field :name, :string

    field :bookables, list_of(:bookable), resolve: dataloader(Bookable)
  end

  object :bookable do
    field :id, :id
    field :name, :string

    field :bookings, list_of(:booking), resolve: dataloader(Booking)
    field :location, :location, resolve: dataloader(Location)
  end

  object :booking do
    field :id, :id
    field :label, :string

    field :bookable, :bookable, resolve: dataloader(Bookable)
  end

  query do
    field :locations, list_of(:location), resolve: &all_locations/3

    field :location, :location do
      arg(:id, non_null(:id))
      resolve(&location/3)
    end
  end

  defp all_locations(_, _, _), do: {:ok, Location |> Repo.all()}

  defp location(_, %{id: id}, _), do: {:ok, Location |> Repo.get(id)}

  defp ecto_query(queryable, _params), do: queryable

  def context(ctx) do
    source = Dataloader.Ecto.new(Repo, query: &ecto_query/2)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Bookable, source)
      |> Dataloader.add_source(Location, source)
      |> Dataloader.add_source(Booking, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
end
