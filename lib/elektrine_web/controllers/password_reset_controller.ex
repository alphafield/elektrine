defmodule ElektrineWeb.PasswordResetController do
  use ElektrineWeb, :controller

  alias Elektrine.Accounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_recovery_email(email) do
      Accounts.create_password_reset_token(user)
    end

    conn
    |> put_flash(:info, "If an account exists with that recovery email, you will receive password reset instructions.")
    |> redirect(to: ~p"/")
  end

  def edit(conn, %{"token" => token}) do
    case Accounts.get_valid_reset_token(token) do
      {:ok, reset_token} ->
        changeset = Accounts.change_user_password(reset_token.user)
        render(conn, :edit, changeset: changeset, token: token)
      {:error, :invalid_token} ->
        conn
        |> put_flash(:error, "Password reset link is invalid or has expired.")
        |> redirect(to: ~p"/")
    end
  end

  def update(conn, %{"token" => token, "user" => %{"password" => password}}) do
    case Accounts.get_valid_reset_token(token) do
      {:ok, reset_token} ->
        case Accounts.reset_password_with_token(reset_token, password) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Password reset successfully. Please log in with your new password.")
            |> redirect(to: ~p"/login")
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Password reset failed. Please try again.")
            |> redirect(to: ~p"/reset-password/#{token}")
        end
      {:error, :invalid_token} ->
        conn
        |> put_flash(:error, "Password reset link is invalid or has expired.")
        |> redirect(to: ~p"/")
    end
  end
end
