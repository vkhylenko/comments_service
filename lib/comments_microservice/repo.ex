defmodule Comments.Repo do
  use Ecto.Repo,
    otp_app: :comments_microservice,
    adapter: Ecto.Adapters.Postgres
end
