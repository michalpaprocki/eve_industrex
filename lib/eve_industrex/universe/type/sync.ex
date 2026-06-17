defmodule EveIndustrex.Universe.Type.Sync do
  alias EveIndustrex.Utils
  @types_url "https://esi.evetech.net/latest/universe/types/"
  def fetch_type_from_ESI!(type_id) do
    Utils.fetch_from_url!(@types_url<>Integer.to_string(type_id))
  end
  def fetch_types_from_ESI!(type_ids) do

    # todo handle errs
    Task.async_stream(type_ids, fn type_id -> Utils.fetch_from_url!(@types_url<>Integer.to_string(type_id)) end) |> Enum.map(fn {:ok, t} -> t end)
  end
end
