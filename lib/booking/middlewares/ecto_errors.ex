defmodule Booking.Middlewares.EctoErrors do
  @behaviour Absinthe.Middleware
  @impl true
  def call(resolution, _) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  @spec handle_error(Ecto.Changeset.t()) :: list(String.t())
  defp handle_error(changeset = %Ecto.Changeset{}) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end

  defp handle_error(error), do: [error]
end
