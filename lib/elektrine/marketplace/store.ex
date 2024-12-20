defmodule Elektrine.Marketplace.Store do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stores" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :status, :string, default: "active"
    field :logo, :string
    field :banner, :string
    field :policies, :string

    belongs_to :owner, Elektrine.Accounts.User
    has_many :products, Elektrine.Marketplace.Product

    timestamps()
  end

  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :description, :slug, :status, :logo, :banner, :policies])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 1000)
    |> validate_inclusion(:status, ~w(active inactive suspended))
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        slug = name
               |> String.downcase()
               |> String.replace(~r/[^a-z0-9\s-]/, "")
               |> String.replace(~r/\s+/, "-")
               |> ensure_unique_slug()
        put_change(changeset, :slug, slug)
    end
  end

  defp ensure_unique_slug(slug) do
    case Elektrine.Repo.get_by(__MODULE__, slug: slug) do
      nil -> slug
      _ -> "#{slug}-#{System.unique_integer([:positive])}"
    end
  end
end
