defmodule ElektrineWeb.AuthErrorHandler do
  use ElektrineWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: to_string(type)})
  end
end
