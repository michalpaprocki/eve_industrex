defmodule EveIndustrex.Scraper do
  require Logger

  alias EveIndustrex.Parser
  alias EveIndustrex.Error

  @patch_notes_url "https://www.eveonline.com/news/t/patch-notes"

  @spec get_latest_tq_version() :: {:ok, String.t()} | {:error, map()}
  def get_latest_tq_version do
    with {:ok, body} <- fetch_patch_notes_html(),
      {:ok, path} <- Parser.parse_html_to_latest_patch_notes_path(body),
      {:ok, version} <- Parser.parse_path_to_tq_version(path) do
      {:ok, version}
    else
      {:error, reason} ->
        {:error, Error.new(:scraper_failed, reason, %{module: __MODULE__})}
    end
  end

  defp fetch_patch_notes_html do
    fetch_html_content(@patch_notes_url)
  end

  defp fetch_html_content(url) do
    case Req.get(url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, Error.new(:http_error, status, %{url: url})}

      {:error, exception} ->
        {:error, Error.new(:request_failed, exception, %{url: url})}
    end
  end
end
