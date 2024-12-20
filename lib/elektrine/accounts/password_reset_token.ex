defmodule Elektrine.Accounts.PasswordResetToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "password_reset_tokens" do
    field :token, :string
    field :used_at, :naive_datetime
    field :expires_at, :naive_datetime
    belongs_to :user, Elektrine.Accounts.User

    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :used_at, :expires_at, :user_id])
    |> validate_required([:token, :expires_at, :user_id])
    |> unique_constraint(:token)
  end
end
