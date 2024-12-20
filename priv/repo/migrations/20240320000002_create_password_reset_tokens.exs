defmodule Elektrine.Repo.Migrations.CreatePasswordResetTokens do
  use Ecto.Migration

  def change do
    create table(:password_reset_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :string, null: false
      add :used_at, :naive_datetime
      add :expires_at, :naive_datetime, null: false

      timestamps()
    end

    create unique_index(:password_reset_tokens, [:token])
    create index(:password_reset_tokens, [:user_id])
  end
end
