defmodule EveIndustrexWeb.Seo do
  use Phoenix.Component
  @moduledoc false

  attr :page_description, :string, doc: "Contents rendered inside the `description` tag."
  attr :page_keywords, :string, doc: "Contents rendered inside the `keywords` tag."
  attr :page_title, :string, doc: "Contents rendered inside the `title` tag."

  attr :canonical, :string,
    required: true,
    doc: "Shows preffered link for crawlers."

  #  <link rel="canonical" href={@canonical} />
  def seo(assigns) do
    ~H"""
    <title>{@page_title || "EveIndustrex"}</title>
    <meta name="description" content={@page_description || ""} />
    <meta name="keywords" content={@page_keywords || ""} />
    """
  end
end
