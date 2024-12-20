defmodule Elektrine.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :status, :string, null: false, default: "open"
      add :buyer_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:cart_items) do
      add :quantity, :integer, null: false
      add :cart_id, references(:carts, on_delete: :delete_all), null: false
      add :product_id, references(:products, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:carts, [:buyer_id])
    create index(:cart_items, [:cart_id])
    create index(:cart_items, [:product_id])
    create unique_index(:cart_items, [:cart_id, :product_id])
  end
end
