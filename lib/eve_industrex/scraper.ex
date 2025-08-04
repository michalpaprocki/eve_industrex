defmodule EveIndustrex.Scraper do
  alias EveIndustrex.Parser
  @patch_notes_url "https://www.eveonline.com/news/t/patch-notes"
  @patch_page_url "https://www.eveonline.com/news/view/"

  def get_latest_tq_version() do
    case fetch_patch_notes_html() do
      {:ok, body} ->
        version =
        body
        |> Parser.parse_html_to_latest_patch_notes_path()
        |> Parser.parse_path_to_tq_version()
      {:ok, version}
      error ->
        error
    end

  end



  def fetch_patch_notes_html() do
    case fetch_html_content(@patch_notes_url) do
      {:ok, body} ->
        {:ok, body}
      error ->
        error
    end
  end
  defp fetch_html_content(url) do
    case Req.get(url) do
      {:ok, %Req.Response{:status => 200, :headers => _headers, :body => body, :trailers => _trailers, :private => _private} } ->
        {:ok, body}
      {:ok, %Req.Response{:status => status, :headers => _headers, :body => _body, :trailers => _trailers, :private => _private}} ->
        {:err_responded_with, Integer.to_string(status), url}
      {:error, exception} ->
        {:err_could_not_fetch , exception, url}
    end
  end
end
