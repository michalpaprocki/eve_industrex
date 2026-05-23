defmodule EveIndustrex.Infrastructure.ESI.Sync.RateLimitGroup do
  use Ecto.Schema
  @primary_key {:id, :id, autogenerate: true}
  schema "rate_limit_groups" do
    field :name, :string
    field :limit_capacity, :integer
    field :window_seconds, :integer
    field :estimated_cost, :integer
    field :last_observed_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

end
