defmodule Elektrine.Marketplace.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :status, :string, default: "pending"
    field :total_amount, :decimal
    field :shipping_address, :string
    field :billing_address, :string

    belongs_to :buyer, Elektrine.Accounts.User
    has_many :order_items, Elektrine.Marketplace.OrderItem
    has_many :products, through: [:order_items, :product]

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:status, :total_amount, :shipping_address, :billing_address])
    |> validate_required([:status, :total_amount])
    |> validate_number(:total_amount, greater_than: 0)
    |> validate_inclusion(:status, ~w(pending paid shipped delivered cancelled))
  end
end

defmodule Elektrine.Marketplace.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer
    field :unit_price, :decimal

    belongs_to :order, Elektrine.Marketplace.Order
    belongs_to :product, Elektrine.Marketplace.Product

    timestamps()
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :unit_price])
    |> validate_required([:quantity, :unit_price])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than: 0)
  end
end
