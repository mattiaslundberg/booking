defmodule BookingWeb.LoginController do
  use BookingWeb, :controller

  alias Booking.User

  def login(conn, %{"email" => email, "password" => password}) do
    {valid?, user} = User.get_validated_user(email, password)

    send_token(conn, valid?, user)
  end

  def login(conn, _) do
    conn |> send_resp(403, "Missing required 'email' and/or 'password'")
  end

  defp send_token(conn, true, %{id: id}) do
    token = Phoenix.Token.sign(BookingWeb.Endpoint, "user_auth", id)
    conn |> json(%{token: token})
  end

  defp send_token(conn, _, _) do
    conn |> send_resp(403, "Invalid credentials")
  end
end
