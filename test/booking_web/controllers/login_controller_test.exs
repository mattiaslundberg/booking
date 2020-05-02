defmodule BookingWeb.LoginControllerTest do
  alias Booking.{Repo, User}
  use BookingWeb.ConnCase

  test "Login with valid credentials", %{conn: conn} do
    %{id: user_id} =
      %User{}
      |> User.changeset(%{name: "First", email: "test@example.com", password: "secret"})
      |> Repo.insert!()

    conn = post(conn, "/login", %{email: "test@example.com", password: "secret"})
    assert json_response(conn, 200)

    token = conn.resp_body |> Jason.decode!() |> Map.get("token")
    assert {:ok, ^user_id} = Phoenix.Token.verify(BookingWeb.Endpoint, "user_auth", token)
  end

  test "login with invalid credentials", %{conn: conn} do
    conn = post(conn, "/login", %{email: "test@example.com", password: "invalid"})
    assert conn.status == 403
    assert conn.resp_body =~ "Invalid"
  end

  test "login without credentials", %{conn: conn} do
    conn = post(conn, "/login", %{})
    assert conn.status == 403
    assert conn.resp_body =~ "Missing"
  end
end
