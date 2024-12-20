defmodule Elektrine.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string, null: false, default: "pending"
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :buyer_id, references(:users, on_delete: :nilify_all), null: false
      add :shipping_address, :text
      add :billing_address, :text

      timestamps()
    end

    create table(:order_items) do
      add :quantity, :integer, null: false
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :product_id, references(:products, on_delete: :nilify_all), null: false

      timestamps()
    end

    create index(:orders, [:buyer_id])
    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
  end
end
