defmodule BookingWeb.LoginController do
  use BookingWeb, :controller

  alias Booking.User

  def login(conn, %{"email" => email, "password" => password}) do
    if User.validate_password(email, password) do
      conn |> json(%{token: "1234"})
    else
      conn |> send_resp(403, "Invalid credentials")
    end
  end

  def login(conn, _) do
    conn |> send_resp(403, "Missing required 'email' and/or 'password'")
  end
end
