defmodule ElektrineWeb.Emails.UserEmail do
  import Swoosh.Email
  use ElektrineWeb, :verified_routes

  def password_reset(user, token) do
    base_url = ElektrineWeb.Endpoint.url()
    reset_url = url(~p"/reset-password/#{token.token}")
    full_url = base_url <> reset_url

    new()
    |> to({user.first_name, user.recovery_email})
    |> from({"Elektrine", "noreply@elektrine.com"})
    |> subject("Reset your password")
    |> html_body("""
    <p>Hi #{user.first_name},</p>
    <p>Someone requested a password reset for your account. If this was you, click the link below to reset your password:</p>
    <p><a href="#{full_url}">Reset Password</a></p>
    <p>This link will expire in 1 hour.</p>
    <p>If you didn't request this, you can safely ignore this email.</p>
    """)
  end
end
