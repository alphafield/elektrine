defmodule ElektrineWeb.ProductController do
  use ElektrineWeb, :controller
  import ElektrineWeb.UserAuth

  alias Elektrine.Marketplace
  alias Elektrine.Marketplace.Product

  plug :require_authenticated_user when action not in [:index, :show]
  plug ElektrineWeb.Plugs.EnsureResourceOwner, [resource_type: :product] when action in [:edit, :update, :delete]

  # Public actions
  def index(conn, _params) do
    products = Marketplace.list_products(status: "active")
    render(conn, :index, products: products)
  end

  def show(conn, %{"id" => id}) do
    product = Marketplace.get_product!(id)
    render(conn, :show, product: product)
  end

  # Protected actions
  def new(conn, params) do
    store_id = params["store_id"]
    stores = Marketplace.list_user_stores(conn.assigns.current_user.id)

    # Pre-fill the store_id if it's provided
    changeset = Product.changeset(%Product{store_id: store_id}, %{})
    render(conn, :new, changeset: changeset, stores: stores)
  end

  def create(conn, %{"product" => product_params}) do
    case Marketplace.create_product(product_params, conn.assigns.current_user) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        stores = Marketplace.list_user_stores(conn.assigns.current_user.id)
        render(conn, :new, changeset: changeset, stores: stores)
    end
  end

  def edit(conn, %{"id" => id}) do
    product = Marketplace.get_product!(id)
    stores = Marketplace.list_user_stores(conn.assigns.current_user.id)
    changeset = Product.changeset(product, %{})
    render(conn, :edit, product: product, changeset: changeset, stores: stores)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Marketplace.get_product!(id)

    case Marketplace.update_product(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        stores = Marketplace.list_user_stores(conn.assigns.current_user.id)
        render(conn, :edit, product: product, changeset: changeset, stores: stores)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Marketplace.get_product!(id)
    {:ok, _product} = Marketplace.delete_product(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: ~p"/products")
  end
end
