defmodule ElektrineWeb.Plugs.SecurityHeaders do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_secure_browser_headers()
    |> put_resp_header("x-frame-options", "SAMEORIGIN")
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("x-xss-protection", "1; mode=block")
    |> put_resp_header("x-download-options", "noopen")
    |> put_resp_header("x-permitted-cross-domain-policies", "none")
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
    |> put_resp_header(
      "content-security-policy",
      "default-src 'self'; " <>
        "script-src 'self' 'unsafe-inline' 'unsafe-eval'; " <>
        "style-src 'self' 'unsafe-inline'; " <>
        "img-src 'self' data: blob: https:; " <>
        "font-src 'self'; " <>
        "connect-src 'self' wss: ws:; " <>
        "frame-ancestors 'none'; " <>
        "form-action 'self';"
    )
  end
end
