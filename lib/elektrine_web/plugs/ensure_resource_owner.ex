defmodule ElektrineWeb.Plugs.EnsureResourceOwner do
  import Plug.Conn
  import Phoenix.Controller

  alias Elektrine.Marketplace

  def init(opts), do: opts

  def call(conn, opts) do
    resource_type = Keyword.fetch!(opts, :resource_type)
    id_param = Keyword.get(opts, :id_param, "id")

    case conn.params[id_param] do
      nil ->
        conn
      id ->
        if authorized?(conn, resource_type, id) do
          conn
        else
          conn
          |> put_flash(:error, "You are not authorized to access this resource")
          |> redirect(to: "/")
          |> halt()
        end
    end
  end

  defp authorized?(conn, resource_type, id) do
    user_id = conn.assigns.current_user.id

    case resource_type do
      :order ->
        order = Marketplace.get_order!(id)
        order.buyer_id == user_id
      :store ->
        store = Marketplace.get_store!(id)
        store.owner_id == user_id
      :product ->
        product = Marketplace.get_product!(id)
        product.seller_id == user_id
      _ ->
        false
    end
  rescue
    Ecto.NoResultsError -> false
  end
end
