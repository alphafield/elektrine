defmodule ElektrineWeb.Plugs.FetchCurrentUser do
  import Plug.Conn

  alias Elektrine.Accounts.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
