defmodule Booking.Schema do
  use Absinthe.Schema
  alias Booking.{Location, Bookable, Repo, Booking}
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  import_types(Absinthe.Type.Custom)

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

    field :start, :datetime
    field :end, :datetime

    field :bookable, :bookable, resolve: dataloader(Bookable)
  end

  query do
    field :locations, list_of(:location), resolve: &Location.all/3

    field :location, :location do
      arg(:id, non_null(:id))
      resolve(&Location.by_id/3)
    end
  end

  mutation do
    @desc "Create a bookable"
    field :create_bookable, type: :bookable do
      arg(:name, non_null(:string))
      arg(:location_id, non_null(:integer))

      resolve(&Bookable.create/3)
    end
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Repo)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Bookable, source)
      |> Dataloader.add_source(Location, source)
      |> Dataloader.add_source(Booking, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
end
