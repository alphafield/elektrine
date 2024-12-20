defmodule ElektrineWeb.Plugs.RateLimiter do
  import Plug.Conn
  require Logger

  @max_requests 100
  @timeframe_ms 60_000

  def init(opts), do: opts

  def call(conn, _opts) do
    client_ip = to_string(:inet.ntoa(conn.remote_ip))
    rate_limit_key = "rate_limit:#{client_ip}"

    case Hammer.check_rate(rate_limit_key, @timeframe_ms, @max_requests) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> put_status(429)
        |> Phoenix.Controller.put_root_layout({ElektrineWeb.Layouts, :error})
        |> Phoenix.Controller.put_view(ElektrineWeb.ErrorHTML)
        |> Phoenix.Controller.render("429.html")
        |> halt()
    end
  end
end
