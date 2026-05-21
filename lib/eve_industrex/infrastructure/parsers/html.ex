defmodule EveIndustrex.Infrastructure.Parsers.Html do

  def parse_html_to_latest_patch_notes_path(html) do
    case extract_patch_path(html) do
      nil ->
        {:error, %{type: :parse_error, reason: :patch_path_not_found}}

      path ->
        {:ok, path}
    end
  end
  defp extract_patch_path(html) do
    html
    |> String.split("<")
    |> Enum.find(fn string -> String.contains?(string, "/news/view") end)
    |> case do
      nil ->
        nil

      match ->
        match
        |> String.split("\"")
        |> Enum.at(1)
        |> case do
          nil -> nil
          url -> extract_slug(url)
        end
      end
  end

  defp extract_slug(url) do
    case String.split(url, "/") do
      [_, _, _, slug | _] -> slug
      _ -> nil
    end
  end
  def parse_path_to_tq_version(path) do
    case do_parse_version(path) do
      nil ->
        {:error, %{type: :parse_error, reason: :invalid_version_format, path: path}}

      version ->
        {:ok, version}
    end
  end

  defp do_parse_version(path) do
    parts = String.split(path, "-")

    cond do
      String.contains?(path, "expansion") ->
        parts |> Enum.take(2) |> Enum.join(" ")

      length(parts) >= 2 ->
        parts |> Enum.take(-2) |> Enum.join(".")

      true ->
        nil
    end
  end
end
