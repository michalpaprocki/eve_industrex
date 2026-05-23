defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncCache do
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  use Ecto.Schema
  @primary_key {:id, :id, autogenerate: true}
  schema "esi_sync_caches" do
    belongs_to :esi_sync_strategy, EsiSyncStrategy, foreign_key: :esi_sync_strategy_id
    field :etag, :string
    field :expires_at, :utc_datetime
    field :page_number, :integer
    field :last_checked_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

end
