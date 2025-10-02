defmodule PermitPlayground.Repo do
  use Ecto.Repo,
    otp_app: :permit_playground,
    adapter: Ecto.Adapters.Postgres
end
