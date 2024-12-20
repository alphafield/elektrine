defmodule Elektrine.Repo.Migrations.CreateUserUsernameUpdates do
  use Ecto.Migration

  def change do
    create table(:user_username_updates) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :old_username, :string, null: false
      add :new_username, :string, null: false

      timestamps()
    end

    create index(:user_username_updates, [:user_id])
  end
end
