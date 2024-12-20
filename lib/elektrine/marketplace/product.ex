defmodule Elektrine.Marketplace.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :title, :string
    field :description, :string
    field :price, :decimal
    field :quantity, :integer
    field :status, :string, default: "draft"
    field :images, {:array, :string}, default: []

    belongs_to :seller, Elektrine.Accounts.User
    belongs_to :store, Elektrine.Marketplace.Store
    has_many :order_items, Elektrine.Marketplace.OrderItem

    timestamps()
  end

  def changeset(product, attrs) do
    # Process images if they come as a comma-separated string
    attrs = process_images(attrs)

    product
    |> cast(attrs, [:title, :description, :price, :quantity, :status, :store_id, :images])
    |> validate_required([:title, :price, :quantity, :status, :store_id])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_inclusion(:status, ~w(draft active inactive))
    |> foreign_key_constraint(:store_id)
  end

  defp process_images(%{"images" => images} = attrs) when is_binary(images) do
    images = images
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.reject(&(&1 == ""))
    %{attrs | "images" => images}
  end
  defp process_images(attrs), do: attrs
end
