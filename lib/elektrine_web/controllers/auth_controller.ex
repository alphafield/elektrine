defmodule ElektrineWeb.AuthController do
  use ElektrineWeb, :controller

  alias Elektrine.Accounts
  alias Elektrine.Accounts.{User, Guardian}

  def register(conn, %{"user" => user_params}) when is_map_key(user_params, "username") do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Account created successfully!")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error creating account")
        |> render(:register, changeset: changeset)
    end
  end

  def register(conn, _params) do
    changeset = User.registration_changeset(%User{}, %{})
    render(conn, :register, changeset: changeset)
  end

  def login(conn, %{"user" => user_params}) do
    username = user_params["username"]
    password = user_params["password"]
    email = "#{username}@elektrine.com"

    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username or password")
        |> render(:login, changeset: User.login_changeset())
    end
  end

  def login(conn, _params) do
    changeset = User.login_changeset()
    render(conn, :login, changeset: changeset)
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/login")
  end
end
