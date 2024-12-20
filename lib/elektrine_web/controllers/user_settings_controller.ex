defmodule ElektrineWeb.UserSettingsController do
  use ElektrineWeb, :controller

  alias Elektrine.Accounts

  def edit(conn, _params) do
    user = conn.assigns.current_user
    username_changeset = Accounts.change_user_username(user)
    password_changeset = Accounts.change_user_password(user)
    recovery_email_changeset = Accounts.change_user_recovery_email(user)
    avatar_changeset = Accounts.change_user_avatar(user)

    render(conn, :edit,
      username_changeset: username_changeset,
      password_changeset: password_changeset,
      recovery_email_changeset: recovery_email_changeset,
      avatar_changeset: avatar_changeset
    )
  end

  def update_username(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_username(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Username updated successfully.")
        |> redirect(to: ~p"/settings")

      {:error, changeset} ->
        error_message = changeset.errors
          |> Keyword.get(:username)
          |> case do
            {msg, _} -> msg
            _ -> "Invalid username"
          end

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: ~p"/settings")
    end
  end

  def update_recovery_email(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_recovery_email(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Recovery email updated successfully.")
        |> redirect(to: ~p"/settings")

      {:error, changeset} ->
        error_message = changeset.errors
          |> Keyword.get(:recovery_email)
          |> case do
            {msg, _} -> msg
            _ -> "Invalid email format"
          end

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: ~p"/settings")
    end
  end

  def update_password(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_password(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: ~p"/settings")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to update password")
        |> redirect(to: ~p"/settings")
    end
  end

  def update_avatar(conn, %{"user" => %{"avatar" => avatar_params}}) do
    user = conn.assigns.current_user

    case Accounts.update_avatar(user, %{avatar: handle_avatar_upload(avatar_params)}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Avatar updated successfully.")
        |> redirect(to: ~p"/settings")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to update avatar.")
        |> redirect(to: ~p"/settings")
    end
  end

  defp handle_avatar_upload(upload) do
    extension = Path.extname(upload.filename)
    filename = "#{Ecto.UUID.generate()}#{extension}"
    File.cp!(upload.path, Path.join("priv/static/uploads", filename))
    "/uploads/#{filename}"
  end
end
