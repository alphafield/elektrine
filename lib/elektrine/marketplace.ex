defmodule Elektrine.Marketplace do
  import Ecto.Query
  alias Elektrine.Repo
  alias Elektrine.Marketplace.{Product, Order, OrderItem, Store, Cart, CartItem}

  # Store functions
  def list_user_stores(user_id) do
    Store
    |> where([s], s.owner_id == ^user_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  def get_store!(id) do
    Store
    |> Repo.get!(id)
    |> Repo.preload(:products)
  end

  def get_store_by_slug!(slug) do
    Store
    |> where([s], s.slug == ^slug)
    |> preload(:products)
    |> Repo.one!()
  end

  def create_store(attrs, owner) do
    %Store{}
    |> Store.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  def update_store(%Store{} = store, attrs) do
    store
    |> Store.changeset(attrs)
    |> Repo.update()
  end

  def delete_store(%Store{} = store) do
    Repo.delete(store)
  end

  # Product functions
  def list_products(opts \\ []) do
    status = Keyword.get(opts, :status, "active")
    seller_id = Keyword.get(opts, :seller_id)
    store_id = Keyword.get(opts, :store_id)

    Product
    |> where([p], p.status == ^status)
    |> filter_by_seller(seller_id)
    |> filter_by_store(store_id)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  defp filter_by_seller(query, nil), do: query
  defp filter_by_seller(query, seller_id) do
    where(query, [p], p.seller_id == ^seller_id)
  end

  defp filter_by_store(query, nil), do: query
  defp filter_by_store(query, store_id) do
    where(query, [p], p.store_id == ^store_id)
  end

  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([:seller, :store])
  end

  def create_product(attrs, seller) do
    # Verify the store belongs to the seller
    store = get_store!(attrs["store_id"])

    if store.owner_id == seller.id do
      %Product{}
      |> Product.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:seller, seller)
      |> Repo.insert()
    else
      {:error, :unauthorized}
    end
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  defp process_images(%{"images" => images} = attrs) when is_binary(images) do
    images = images
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.reject(&(&1 == ""))
    %{attrs | "images" => images}
  end
  defp process_images(attrs), do: attrs

  # Order functions
  def create_order(attrs, buyer, cart_items) do
    # Calculate total amount from cart items
    total_amount = Enum.reduce(cart_items, Decimal.new(0), fn item, acc ->
      Decimal.add(acc, Decimal.mult(item.product.price, Decimal.new(item.quantity)))
    end)

    # Ensure all keys are strings
    attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)
    attrs = Map.put(attrs, "total_amount", total_amount)

    Repo.transaction(fn ->
      # Create order
      order =
        %Order{}
        |> Order.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:buyer, buyer)
        |> Repo.insert!()

      # Create order items and update product quantities
      Enum.each(cart_items, fn cart_item ->
        product = cart_item.product

        if product.quantity >= cart_item.quantity do
          # Create order item
          %OrderItem{}
          |> OrderItem.changeset(%{
            quantity: cart_item.quantity,
            unit_price: product.price
          })
          |> Ecto.Changeset.put_assoc(:order, order)
          |> Ecto.Changeset.put_assoc(:product, product)
          |> Repo.insert!()

          # Update product quantity
          product
          |> Product.changeset(%{quantity: product.quantity - cart_item.quantity})
          |> Repo.update!()

          # Delete cart item
          Repo.delete!(cart_item)
        else
          Repo.rollback(:insufficient_stock)
        end
      end)

      order
    end)
  end

  def get_order!(id) do
    Order
    |> preload([:order_items, order_items: :product])
    |> Repo.get!(id)
  end

  def list_user_orders(user_id) do
    Order
    |> where([o], o.buyer_id == ^user_id)
    |> order_by([o], desc: o.inserted_at)
    |> preload([:order_items, order_items: :product])
    |> Repo.all()
  end

  def update_order_status(%Order{} = order, status) do
    order
    |> Order.changeset(%{status: status})
    |> Repo.update()
  end

  def get_cart!(user_id) do
    Cart
    |> where([c], c.buyer_id == ^user_id and c.status == "open")
    |> first()
    |> Repo.one()
    |> case do
      nil -> create_cart(user_id)
      cart -> cart |> Repo.preload([:buyer, cart_items: [product: :store]])
    end
  end

  defp create_cart(user_id) do
    buyer = Repo.get!(Elektrine.Accounts.User, user_id)

    %Cart{}
    |> Cart.changeset(%{status: "open"})
    |> Ecto.Changeset.put_assoc(:buyer, buyer)
    |> Repo.insert!()
    |> Repo.preload([:buyer, cart_items: [product: :store]])
  end

  def add_to_cart(cart, product_id, quantity) do
    product = get_product!(product_id)

    if product.quantity >= quantity do
      case Repo.get_by(CartItem, cart_id: cart.id, product_id: product_id) do
        nil ->
          %CartItem{}
          |> CartItem.changeset(%{quantity: quantity, product_id: product_id})
          |> Ecto.Changeset.put_assoc(:cart, cart)
          |> Repo.insert()

        cart_item ->
          new_quantity = cart_item.quantity + quantity
          if product.quantity >= new_quantity do
            cart_item
            |> CartItem.changeset(%{quantity: new_quantity})
            |> Repo.update()
          else
            {:error, :insufficient_stock}
          end
      end
    else
      {:error, :insufficient_stock}
    end
  end

  def update_cart_item(cart_item, quantity) do
    if cart_item.product.quantity >= quantity do
      cart_item
      |> CartItem.changeset(%{quantity: quantity})
      |> Repo.update()
    else
      {:error, :insufficient_stock}
    end
  end

  def remove_from_cart(cart_item_id) do
    CartItem
    |> Repo.get!(cart_item_id)
    |> Repo.delete()
  end

  def checkout_cart(cart) do
    cart = cart |> Repo.preload(cart_items: [product: :store])

    Repo.transaction(fn ->
      # Create order with string keys
      {:ok, order} = create_order(%{"status" => "pending"}, cart.buyer, cart.cart_items)

      # Update cart status
      cart
      |> Cart.changeset(%{status: "completed"})
      |> Repo.update!()

      order
    end)
  end

  # Add this function to get a cart item
  def get_cart_item!(id) do
    CartItem
    |> Repo.get!(id)
    |> Repo.preload(product: :store)
  end
end
