defmodule ElektrineWeb.CartController do
  use ElektrineWeb, :controller

  alias Elektrine.Marketplace

  def show(conn, _params) do
    cart = Marketplace.get_cart!(conn.assigns.current_user.id)
    render(conn, :show, cart: cart)
  end

  def add_item(conn, %{"product_id" => product_id, "quantity" => quantity}) do
    cart = Marketplace.get_cart!(conn.assigns.current_user.id)
    quantity = String.to_integer(quantity)

    case Marketplace.add_to_cart(cart, product_id, quantity) do
      {:ok, _cart_item} ->
        conn
        |> put_flash(:info, "Item added to cart successfully.")
        |> redirect(to: ~p"/cart")

      {:error, :insufficient_stock} ->
        conn
        |> put_flash(:error, "Insufficient stock.")
        |> redirect(to: ~p"/products/#{product_id}")
    end
  end

  def update_item(conn, %{"id" => id, "quantity" => quantity}) do
    cart_item = Marketplace.get_cart_item!(id)
    quantity = String.to_integer(quantity)

    case Marketplace.update_cart_item(cart_item, quantity) do
      {:ok, _cart_item} ->
        conn
        |> put_flash(:info, "Cart updated successfully.")
        |> redirect(to: ~p"/cart")

      {:error, :insufficient_stock} ->
        conn
        |> put_flash(:error, "Insufficient stock.")
        |> redirect(to: ~p"/cart")
    end
  end

  def delete_item(conn, %{"id" => id}) do
    {:ok, _cart_item} = Marketplace.remove_from_cart(id)

    conn
    |> put_flash(:info, "Item removed from cart.")
    |> redirect(to: ~p"/cart")
  end

  def checkout(conn, _params) do
    cart = Marketplace.get_cart!(conn.assigns.current_user.id)

    case Marketplace.checkout_cart(cart) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order placed successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: ~p"/cart")
    end
  end
end
