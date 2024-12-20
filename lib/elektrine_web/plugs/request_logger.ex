defmodule ElektrineWeb.Plugs.RequestLogger do
  require Logger
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    start_time = System.monotonic_time()

    register_before_send(conn, fn conn ->
      stop_time = System.monotonic_time()
      diff = System.convert_time_unit(stop_time - start_time, :native, :millisecond)

      Logger.info(
        "#{conn.method} #{conn.request_path} -> #{conn.status} " <>
          "(#{diff}ms) - IP: #{:inet.ntoa(conn.remote_ip)}"
      )

      conn
    end)
  end
end
