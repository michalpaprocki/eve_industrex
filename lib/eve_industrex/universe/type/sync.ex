defmodule EveIndustrex.Universe.Type.Sync do
  alias EveIndustrex.Infrastructure.ESI.Client
  alias EveIndustrex.Utils
  @moduledoc false
  @types_url "https://esi.evetech.net/latest/universe/types/"
  def fetch_type_from_esi(type_id) do
    case Client.fetch_type(type_id) do
      {:ok, response} ->
        {:ok, response}

      {:error, exception} ->
        {:error, exception}
    end
  end

  def fetch_types_from_esi!(type_ids) do
    # todo handle errs
    Task.async_stream(type_ids, fn type_id ->
      Utils.fetch_from_url!(@types_url <> Integer.to_string(type_id))
    end)
    |> Enum.map(fn {:ok, t} -> t end)
  end
end
