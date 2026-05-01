defmodule EveIndustrex.TqVersionService do
  alias EveIndustrex.Schemas.TqVersion
  alias EveIndustrex.Repo

   def upsert_tq_version(string) do
    get_tq_version()
    |> TqVersion.changeset(%{:version => string})
    |> Repo.insert_or_update()
  end
  def get_tq_version() do
    case Repo.one(TqVersion) do
      nil ->
        %TqVersion{}
      version ->
        version
    end
  end
end
