defmodule LogbookElixWeb.Plugs.RateLimiter do
  @moduledoc """
  Rate limiting plug using Hammer library.
  Limits requests per user based on their authenticated user ID.
  """

  import Plug.Conn
  alias LogbookElix.Auth.Guardian

  @doc """
  Initialize the rate limiter with options.

  Options:
    - :limit - number of requests allowed (default: 10)
    - :window_ms - time window in milliseconds (default: 60_000 for 1 minute)
    - :bucket_prefix - prefix for rate limit bucket (default: "api")
  """
  def init(opts) do
    %{
      limit: Keyword.get(opts, :limit, 10),
      window_ms: Keyword.get(opts, :window_ms, 60_000),
      bucket_prefix: Keyword.get(opts, :bucket_prefix, "api")
    }
  end

  def call(conn, %{limit: limit, window_ms: window_ms, bucket_prefix: bucket_prefix}) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        # No authenticated user, skip rate limiting (auth will handle this)
        conn

      user ->
        bucket = "#{bucket_prefix}:#{user.id}"

        case LogbookElix.RateLimiter.hit(bucket, window_ms, limit) do
          {:allow, _count} ->
            conn

          {:deny, _limit} ->
            conn
            |> put_status(:too_many_requests)
            |> put_resp_content_type("application/json")
            |> send_resp(
              429,
              Jason.encode!(%{
                error: "Rate limit exceeded",
                message: "Too many requests. Please try again later."
              })
            )
            |> halt()
        end
    end
  end
end
