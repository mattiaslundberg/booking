defmodule Booking.Schema do
  use Absinthe.Schema
  alias Booking.{Location, Bookable, Repo, User}
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  @moduledoc """
  Main absinthe schema
  """

  import_types(Absinthe.Type.Custom)

  @desc "User with permission"
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string

    field :locations, list_of(:location), resolve: dataloader(Location)
  end

  @desc "The location where the booking is done, for example restaurant"
  object :location do
    field :id, :id
    field :name, :string

    field :bookables, list_of(:bookable), resolve: dataloader(Bookable)
    field :users, list_of(:user), resolve: dataloader(User)
  end

  @desc "The thing that is bookable, for example table at restaurant"
  object :bookable do
    field :id, :id
    field :name, :string

    field :bookings, list_of(:booking), resolve: dataloader(Booking.Booking)
    field :location, :location, resolve: dataloader(Location)
  end

  @desc "The specific booking, for example table reservation at 19"
  object :booking do
    field :id, :id
    field :label, :string

    field :start, :datetime
    field :end, :datetime

    field :bookable, :bookable, resolve: dataloader(Bookable)
  end

  query do
    @desc "List the locations"
    field :locations, list_of(:location), resolve: &Location.all/3

    @desc "Get specific location by known id"
    field :location, :location do
      arg(:id, non_null(:id))
      resolve(&Location.by_id/3)
    end
  end

  mutation do
    @desc "Create user"
    field :create_user, type: :user do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:location_id, non_null(:integer))

      resolve(&User.create/3)
    end

    @desc "Create a bookable"
    field :create_bookable, type: :bookable do
      arg(:name, non_null(:string))
      arg(:location_id, non_null(:integer))

      resolve(&Bookable.create/3)
    end

    @desc "Update bookable"
    field :update_bookable, type: :bookable do
      arg(:id, non_null(:id))
      arg(:name, non_null(:string))
      arg(:location_id, non_null(:integer))

      resolve(&Bookable.update/3)
    end

    @desc "Create a booking"
    field :create_booking, type: :booking do
      arg(:label, non_null(:string))
      arg(:bookable_id, non_null(:integer))
      arg(:start, non_null(:datetime))
      arg(:end, non_null(:datetime))

      resolve(&Booking.Booking.create/3)
    end

    @desc "Update booking"
    field :update_booking, type: :booking do
      arg(:id, non_null(:id))
      arg(:label, non_null(:string))
      arg(:bookable_id, non_null(:integer))
      arg(:start, non_null(:datetime))
      arg(:end, non_null(:datetime))

      resolve(&Booking.Booking.update/3)
    end
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Repo)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Bookable, source)
      |> Dataloader.add_source(Location, source)
      |> Dataloader.add_source(User, source)
      |> Dataloader.add_source(Booking.Booking, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()

  def middleware(middleware, _field, %{identifier: :mutation}),
    do: middleware ++ [Booking.Middlewares.EctoErrors]

  def middleware(middleware, _field, _object), do: middleware
end
