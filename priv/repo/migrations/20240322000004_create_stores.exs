defmodule Elektrine.Repo.Migrations.CreateStores do
  use Ecto.Migration

  def change do
    create table(:stores) do
      add :name, :string, null: false
      add :description, :text
      add :slug, :string, null: false
      add :status, :string, null: false, default: "active"
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :logo, :string
      add :banner, :string
      add :policies, :text

      timestamps()
    end

    create unique_index(:stores, [:slug])
    create index(:stores, [:owner_id])
    create index(:stores, [:status])

    # Add store_id to products
    alter table(:products) do
      add :store_id, references(:stores, on_delete: :delete_all), null: false
    end

    create index(:products, [:store_id])
  end
end
