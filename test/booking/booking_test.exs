defmodule Booking.BookingTest do
  use ExUnit.Case
  alias Booking.Booking

  setup do
    booking = %Booking{label: "Booking", bookable_id: 3}

    %{booking: booking}
  end

  test "validate start < end in changes" do
    changeset =
      %Booking{}
      |> Booking.changeset(%{
        label: "Booking",
        bookable_id: 3,
        start: DateTime.utc_now(),
        end: DateTime.add(DateTime.utc_now(), 1000)
      })

    assert changeset.valid?
  end

  test "validate start > end in changes" do
    changeset =
      %Booking{}
      |> Booking.changeset(%{
        label: "Booking",
        bookable_id: 3,
        start: DateTime.utc_now(),
        end: DateTime.add(DateTime.utc_now(), -1000)
      })

    refute changeset.valid?
  end

  test "validate start == end in changes" do
    now = DateTime.utc_now()

    changeset =
      %Booking{}
      |> Booking.changeset(%{
        label: "Booking",
        bookable_id: 3,
        start: now,
        end: now
      })

    assert changeset.valid?
  end

  test "change start to invalid value" do
    now = DateTime.utc_now()

    changeset =
      %Booking{label: "Booking", bookable_id: 3, start: now, end: now}
      |> Booking.changeset(%{
        start: DateTime.add(now, 10000)
      })

    refute changeset.valid?
  end

  test "change end to invalid value" do
    now = DateTime.utc_now()

    changeset =
      %Booking{label: "Booking", bookable_id: 3, start: now, end: now}
      |> Booking.changeset(%{
        end: DateTime.add(now, -10000)
      })

    refute changeset.valid?
  end
end
