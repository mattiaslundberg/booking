defmodule BookingWeb.Router do
  use BookingWeb, :router

  @spec get_token(Plug.Conn.t()) :: String.t() | nil
  defp get_token(%{req_headers: headers}),
    do: headers |> Enum.into(%{}) |> Map.get("x-user-token")

  @spec is_authenticated({:ok | :error, Integer.t() | String.t()}, Plug.Conn.t()) :: Plug.Conn.t()
  defp is_authenticated({:ok, user_id}, conn) do
    conn |> assign(:user_id, user_id)
  end

  defp is_authenticated(_, conn), do: conn

  defp send_response(conn = %{assigns: %{user_id: _id}}), do: conn
  defp send_response(conn), do: conn |> send_resp(403, "Not accessible") |> halt()

  @spec authenticate_user(Plug.Conn.t(), []) :: Plug.Conn.t()
  defp authenticate_user(conn, _params) do
    conn
    |> get_token()
    |> (fn t -> Phoenix.Token.verify(BookingWeb.Endpoint, "user_auth", t) end).()
    |> is_authenticated(conn)
    |> send_response()
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :authenticate_user
  end

  scope "/", BookingWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/" do
    pipe_through(:api)

    post "/login", BookingWeb.LoginController, :login
  end

  scope "/" do
    pipe_through(:graphql)
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: Booking.Schema
    forward "/graphql", Absinthe.Plug, schema: Booking.Schema
  end

  # Other scopes may use custom stacks.
  # scope "/api", BookingWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BookingWeb.Telemetry
    end
  end
end
