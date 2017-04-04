defmodule Xtorrent.Crawlers.EZTVParser do
  @url "https://eztv.ag/"

  def paginated_links do
    1..2 |> Enum.map(fn i -> {:page_link, "https://eztv.ag/page_#{i}"} end)
  end

  def torrent_links(body) do
    body
    |> Floki.find("a.epinfo")
    |> Floki.attribute("href")
    |> Enum.filter(fn(a) -> String.contains?(a, "/ep/") end)
    |> Enum.map(fn(url) -> @url <> url end)
  end

  def extract_torrent_data(body) do
    %{
      name: name(body),
      magnet_link: magnet_link(body)
    }
  end

  defp name(html) do
    html
    |> Floki.find("td.section_post_header")
    |> Enum.at(0)
    |> Floki.text
  end

  defp magnet_link(html) do
    html
    |> Floki.find("a[href^=magnet]")
    |> Enum.at(0)
    |> Floki.attribute("href")
    |> Enum.at(0)
  end
end
