defmodule ElektrineWeb.StoreController do
  use ElektrineWeb, :controller
  import ElektrineWeb.UserAuth

  alias Elektrine.Marketplace
  alias Elektrine.Marketplace.Store

  plug :require_authenticated_user when action not in [:show]
  plug ElektrineWeb.Plugs.EnsureResourceOwner, [resource_type: :store] when action in [:edit, :update, :delete]

  # Public action - no auth needed
  def show(conn, %{"slug" => slug}) do
    store = Marketplace.get_store_by_slug!(slug)
    render(conn, :show, store: store)
  end

  # Protected actions
  def index(conn, _params) do
    stores = Marketplace.list_user_stores(conn.assigns.current_user.id)
    render(conn, :index, stores: stores)
  end

  def new(conn, _params) do
    changeset = Store.changeset(%Store{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"store" => store_params}) do
    case Marketplace.create_store(store_params, conn.assigns.current_user) do
      {:ok, store} ->
        conn
        |> put_flash(:info, "Store created successfully.")
        |> redirect(to: ~p"/stores/#{store}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    store = Marketplace.get_store!(id)
    changeset = Store.changeset(store, %{})
    render(conn, :edit, store: store, changeset: changeset)
  end

  def update(conn, %{"id" => id, "store" => store_params}) do
    store = Marketplace.get_store!(id)

    case Marketplace.update_store(store, store_params) do
      {:ok, store} ->
        conn
        |> put_flash(:info, "Store updated successfully.")
        |> redirect(to: ~p"/stores/#{store}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, store: store, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    store = Marketplace.get_store!(id)
    {:ok, _store} = Marketplace.delete_store(store)

    conn
    |> put_flash(:info, "Store deleted successfully.")
    |> redirect(to: ~p"/stores")
  end
end
