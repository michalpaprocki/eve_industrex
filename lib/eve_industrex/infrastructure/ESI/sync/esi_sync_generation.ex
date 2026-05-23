defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGeneration do
   alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncStrategy}
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "esi_sync_generations" do
    belongs_to :esi_sync_strategy, EsiSyncStrategy
    field :priority, :integer
    field :generation, :integer
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :duration_ms, :integer
    field :target_id, :integer
    field :last_error, :string
    field :status, Ecto.Enum, values: [:running, :completed, :failed, :partial]
    timestamps(type: :utc_datetime)
  end

end
