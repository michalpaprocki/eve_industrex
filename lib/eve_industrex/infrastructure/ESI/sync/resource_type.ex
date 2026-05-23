defmodule EveIndustrex.Infrastructure.ESI.Sync.ResourceType do
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :id, autogenerate: true}
  schema "resource_types" do
    field :name, :string
    field :strategies_count, :integer
    has_many :sync_strategies, EsiSyncStrategy
    timestamps(type: :utc_datetime)
  end

  def update_strategies_count_changeset(resource_type, attrs) do
    resource_type
    |> cast(attrs, [:strategies_count])
  end
end
