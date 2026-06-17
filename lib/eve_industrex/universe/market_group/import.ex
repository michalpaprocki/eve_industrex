defmodule EveIndustrex.Universe.MarketGroup.Import do

  alias EveIndustrex.Universe.MarketGroup.Sync
  alias EveIndustrex.Universe.MarketGroup.Mapper
  alias EveIndustrex.Universe.MarketGroup.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_dump do
    jsonl = Jsonl.read_jsonl(Jsonl.get_market_groups_path)
    market_groups = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, mg} -> mg end)
    case Sync.get_market_groups() do
      {:ok, esi_market_groups} ->

        ids = Enum.map(market_groups, fn mg ->
          mg.market_group_id
        end)

        missing = ids -- esi_market_groups

        fetched_market_groups = Sync.update_from_esi(missing)
        |> Enum.map(fn x-> Mapper.from_esi(x)end)

        market_groups = market_groups ++ fetched_market_groups

        Persistence.upsert_all(market_groups)
        Persistence.put_mg_assocs()

      {:error, exception} ->
        raise exception
    end
  end
end
