defmodule ElektrineWeb.PageController do
  use ElektrineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
