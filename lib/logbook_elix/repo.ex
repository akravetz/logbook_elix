defmodule LogbookElix.Repo do
  use Ecto.Repo,
    otp_app: :logbook_elix,
    adapter: Ecto.Adapters.Postgres
end
