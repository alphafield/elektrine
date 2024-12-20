defmodule Elektrine.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :recovery_email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_current_password, :string, virtual: true
    field :first_name, :string
    field :last_name, :string
    field :confirmed_at, :naive_datetime
    field :avatar, :string

    timestamps()
  end

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :password, :first_name, :last_name, :recovery_email])
    |> validate_required([:username, :password, :first_name, :last_name])
    |> validate_username()
    |> validate_recovery_email()
    |> validate_password(opts)
    |> generate_email()
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/, message: "only letters, numbers, and underscores allowed")
    |> validate_length(:username, min: 3, max: 30)
    |> unsafe_validate_unique(:username, Elektrine.Repo)
    |> unique_constraint(:username)
  end

  defp generate_email(changeset) do
    case get_change(changeset, :username) do
      nil -> changeset
      username -> put_change(changeset, :email, "#{username}@elektrine.com")
    end
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!@#$%^&*(),.?":{}|<>]/, message: "at least one symbol")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def login_changeset(user \\ %__MODULE__{}) do
    cast(user, %{}, [:username, :password])
  end

  def username_changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_username()
    |> generate_email()
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :password_current_password, :password_confirmation])
    |> validate_required([:password_current_password])
    |> validate_password([])
    |> validate_confirmation(:password, message: "does not match password")
    |> maybe_hash_password([])
  end

  def recovery_email_changeset(user, attrs) do
    user
    |> cast(attrs, [:recovery_email])
    |> validate_recovery_email()
  end

  defp validate_recovery_email(changeset) do
    changeset
    |> validate_format(:recovery_email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:recovery_email, max: 160)
  end

  def reset_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password([])
    |> maybe_hash_password([])
  end

  def avatar_changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar])
    |> validate_required([:avatar])
  end
end
