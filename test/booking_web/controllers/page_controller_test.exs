defmodule BookingWeb.PageControllerTest do
  use BookingWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "app-container"
  end
end
