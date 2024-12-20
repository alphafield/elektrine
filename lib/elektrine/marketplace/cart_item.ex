defmodule Elektrine.Marketplace.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :quantity, :integer
    belongs_to :cart, Elektrine.Marketplace.Cart
    belongs_to :product, Elektrine.Marketplace.Product

    timestamps()
  end

  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:quantity, :product_id])
    |> validate_required([:quantity, :product_id])
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:cart_id)
  end
end
