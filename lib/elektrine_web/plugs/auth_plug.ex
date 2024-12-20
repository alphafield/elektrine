defmodule ElektrineWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias Elektrine.Accounts.Guardian

  def require_authenticated_user(conn, _opts) do
    if Guardian.Plug.current_resource(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if Guardian.Plug.current_resource(conn) do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end
end
