defmodule Elektrine.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :quantity, :integer, null: false, default: 0
      add :status, :string, null: false, default: "draft"
      add :images, {:array, :string}, default: []
      add :seller_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:products, [:seller_id])
    create index(:products, [:status])
  end
end
