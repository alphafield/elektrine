defmodule Elektrine.Accounts.PasswordValidator do
  def validate(password) when is_binary(password) do
    validations = [
      {String.length(password) >= 12, "Password must be at least 12 characters"},
      {String.match?(password, ~r/[A-Z]/), "Password must contain at least one uppercase letter"},
      {String.match?(password, ~r/[a-z]/), "Password must contain at least one lowercase letter"},
      {String.match?(password, ~r/[0-9]/), "Password must contain at least one number"},
      {String.match?(password, ~r/[^A-Za-z0-9]/), "Password must contain at least one special character"}
    ]

    case Enum.filter(validations, fn {valid, _} -> !valid end) do
      [] -> :ok
      errors -> {:error, Enum.map(errors, fn {_, msg} -> msg end)}
    end
  end

  def validate(_), do: {:error, ["Password must be a string"]}
end
