defmodule ElektrineWeb.OrderController do
  use ElektrineWeb, :controller
  import ElektrineWeb.UserAuth

  alias Elektrine.Marketplace

  plug :require_authenticated_user
  plug ElektrineWeb.Plugs.EnsureResourceOwner, [resource_type: :order] when action in [:show]

  def index(conn, _params) do
    orders = Marketplace.list_user_orders(conn.assigns.current_user.id)
    render(conn, :index, orders: orders)
  end

  def show(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    render(conn, :show, order: order)
  end
end
