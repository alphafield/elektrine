defmodule Elektrine.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
