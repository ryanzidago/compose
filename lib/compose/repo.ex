defmodule Compose.Repo do
  use Ecto.Repo,
    otp_app: :compose,
    adapter: Ecto.Adapters.Postgres
end
