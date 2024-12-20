defmodule Elektrine.Accounts do
  import Ecto.Query
  alias Elektrine.Repo
  alias Elektrine.Accounts.User
  alias Elektrine.Accounts.UserUsernameUpdate
  alias Elektrine.Accounts.PasswordResetToken
  alias Elektrine.Mailer
  alias ElektrineWeb.Emails.UserEmail

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) when is_binary(email) do
    [username, _] = String.split(email, "@")
    Repo.get_by(User, username: username)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        Bcrypt.no_user_verify()
        {:error, :invalid_email}
    end
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  def change_user_username(user, attrs \\ %{}) do
    User.username_changeset(user, attrs)
  end

  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs)
  end

  def update_username(user, attrs) do
    now = NaiveDateTime.utc_now()

    # Get the last username update time from a new table
    last_update = Repo.one(from u in UserUsernameUpdate,
      where: u.user_id == ^user.id,
      order_by: [desc: u.inserted_at],
      limit: 1)

    case last_update do
      nil ->
        # First time update, allow it
        perform_username_update(user, attrs)
      update ->
        minutes_since_update = NaiveDateTime.diff(now, update.inserted_at, :second) / 60

        if minutes_since_update >= 15 do
          perform_username_update(user, attrs)
        else
          minutes_remaining = ceil(15 - minutes_since_update)
          changeset = User.username_changeset(user, attrs)
          {:error, Ecto.Changeset.add_error(changeset, :username,
            "can only be changed every 15 minutes. #{minutes_remaining} minutes remaining")}
        end
    end
  end

  defp perform_username_update(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.username_changeset(user, attrs))
    |> Ecto.Multi.insert(:username_update, fn %{user: updated_user} ->
      %UserUsernameUpdate{
        user_id: updated_user.id,
        old_username: user.username,
        new_username: updated_user.username
      }
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def update_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  def validate_current_password(user, password) do
    if Bcrypt.verify_pass(password, user.hashed_password) do
      :ok
    else
      {:error, "invalid password"}
    end
  end

  def change_user_recovery_email(user, attrs \\ %{}) do
    User.recovery_email_changeset(user, attrs)
  end

  def update_recovery_email(user, attrs) do
    user
    |> User.recovery_email_changeset(attrs)
    |> Repo.update()
  end

  def create_password_reset_token(user) do
    if user.recovery_email do
      token = generate_reset_token()
      expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), 3600, :second)

      attrs = %{
        user_id: user.id,
        token: token,
        expires_at: expires_at
      }

      case Repo.insert(PasswordResetToken.changeset(%PasswordResetToken{}, attrs)) do
        {:ok, token} ->
          UserEmail.password_reset(user, token) |> Mailer.deliver()
          {:ok, token}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :no_recovery_email}
    end
  end

  def get_valid_reset_token(token) do
    now = NaiveDateTime.utc_now()

    query = from t in PasswordResetToken,
      where: t.token == ^token and
             is_nil(t.used_at) and
             t.expires_at > ^now,
      preload: [:user]

    case Repo.one(query) do
      nil -> {:error, :invalid_token}
      token -> {:ok, token}
    end
  end

  def reset_password_with_token(token, password) do
    now = NaiveDateTime.utc_now()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:token, PasswordResetToken.changeset(token, %{used_at: now}))
    |> Ecto.Multi.update(:user, User.reset_password_changeset(token.user, %{password: password}))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp generate_reset_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  def get_user_by_recovery_email(email) when is_binary(email) do
    Repo.get_by(User, recovery_email: email)
  end

  def update_avatar(user, attrs) do
    user
    |> User.avatar_changeset(attrs)
    |> Repo.update()
  end

  def change_user_avatar(user) do
    User.avatar_changeset(user, %{})
  end
end
