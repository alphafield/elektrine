defmodule ElektrineWeb.Plugs.RateLimiterTest do
  use ElektrineWeb.ConnCase

  setup do
    # Clear any rate limit data before each test
    :ok = Application.stop(:hammer)
    :ok = Application.start(:hammer)
    :ok
  end

  describe "rate limiter" do
    test "allows requests within rate limit", %{conn: conn} do
      # Make multiple requests within the limit
      results = for _ <- 1..90 do
        conn = get(conn, ~p"/")
        conn.status != 429
      end

      assert Enum.all?(results)
    end

    test "blocks requests exceeding rate limit", %{conn: conn} do
      # Exceed the rate limit
      for _ <- 1..100 do
        get(conn, ~p"/")
      end

      # This request should be blocked
      conn = get(conn, ~p"/")
      assert conn.status == 429
      assert response_content_type(conn, :html)
      assert response(conn, 429) =~ "Too Many Requests"
    end

    test "rate limits are per IP address", %{conn: conn} do
      # Make requests from first IP
      for _ <- 1..90 do
        get(conn, ~p"/")
      end

      # Change IP address
      conn = %{conn | remote_ip: {192, 168, 1, 2}}

      # Should be allowed for new IP
      conn = get(conn, ~p"/")
      assert response(conn, 200)
    end

    test "rate limit counter resets after timeframe", %{conn: conn} do
      # Make requests up to limit
      for _ <- 1..90 do
        get(conn, ~p"/")
      end

      # Wait for rate limit window to expire
      :timer.sleep(1_100) # Wait just over 1 second for test

      # Should be allowed again
      conn = get(conn, ~p"/")
      assert response(conn, 200)
    end
  end
end
