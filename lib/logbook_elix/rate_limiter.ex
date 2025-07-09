defmodule LogbookElix.RateLimiter do
  @moduledoc """
  Rate limiter module using Hammer with ETS backend.
  """
  use Hammer, backend: :ets
end
