defmodule Elektrine.Marketplace.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    field :status, :string, default: "open"
    belongs_to :buyer, Elektrine.Accounts.User
    has_many :cart_items, Elektrine.Marketplace.CartItem

    timestamps()
  end

  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, ~w(open processing completed))
  end
end
