defmodule Elektrine.Accounts.UserUsernameUpdate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_username_updates" do
    field :old_username, :string
    field :new_username, :string
    belongs_to :user, Elektrine.Accounts.User

    timestamps()
  end

  def changeset(update, attrs) do
    update
    |> cast(attrs, [:user_id, :old_username, :new_username])
    |> validate_required([:user_id, :old_username, :new_username])
  end
end
