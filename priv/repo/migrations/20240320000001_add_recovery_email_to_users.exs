defmodule Elektrine.Repo.Migrations.AddRecoveryEmailToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :recovery_email, :string
    end

    create index(:users, [:recovery_email])
  end
end
