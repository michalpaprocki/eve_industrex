defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy do
  alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncCache ,ResourceType, EsiSyncGeneration}
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :id, autogenerate: true}
  schema "esi_sync_strategies" do
      belongs_to :resource_type, ResourceType
      field :target_id, :integer
      field :sync_interval_seconds, :integer
      field :last_successful_sync, :utc_datetime
      field :enabled, :boolean
      field :next_generation, :integer, default: 1
      field :status, Ecto.Enum, values: [:idle, :scheduled, :running, :paused, :failed, :critical], default: :idle
      field :next_run_at, :utc_datetime
      has_many :caches, EsiSyncCache
      has_many :generations, EsiSyncGeneration

      timestamps(type: :utc_datetime)
  end
  def changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:sync_interval_seconds, :target_id, :last_successful_sync, :status, :next_run_at, :enabled, :next_generation, :resource_type_id])
  end
end
