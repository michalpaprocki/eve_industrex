defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy do
  alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncCache ,ResourceType, EsiSyncGeneration}
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "esi_sync_strategies" do
      belongs_to :resource_type, ResourceType
      field :target_id, :integer
      field :sync_interval_seconds, :integer
      field :last_successful_sync, :utc_datetime
      field :enabled, :boolean
      has_many :caches, EsiSyncCache
      has_many :generations, EsiSyncGeneration
      timestamps(type: :utc_datetime)
  end

end
