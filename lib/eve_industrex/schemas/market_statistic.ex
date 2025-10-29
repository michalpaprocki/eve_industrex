defmodule EveIndustrex.Schemas.MarketStatistic do
  alias EveIndustrex.Schemas.{Type, Region}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_statistics" do
    field :average, :float
    field :date, :date
    field :highest, :float
    field :lowest, :float
    field :order_count, :integer
    field :volume, :integer
    field :type_id, :integer
    field :region_id, :integer
    belongs_to :type, Type, references: :type_id, foreign_key: :type_id, define_field: false
    belongs_to :region, Region, references: :region_id, foreign_key: :region_id, define_field: false
  end

  def changeset(market_statistic, attrs) do
    date_utc = Date.from_iso8601!(attrs["date"])
    attrs_updated = Map.replace(attrs, "date", date_utc)
    market_statistic
    |> cast(attrs_updated, [:average, :date, :highest, :lowest, :order_count, :volume, :type_id, :region_id])
    |> unique_constraint([:date, :type_id, :region_id], name: :unique_date_type_region)
  end
end
