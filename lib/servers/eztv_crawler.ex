defmodule Xtorrent.Servers.EztvCrawler do
  use GenServer
  alias Xtorrent.Crawlers.EZTVParser
  alias Xtorrent.Connection

  def start_link do
    queue = build_queue_urls()
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1 * 1 * 100)
  end

  def handle_info(:work, queue) do
    queue = case :queue.out(queue) do
      {{_value, item}, new_queue} ->
        process(item, new_queue)
      _ ->
        IO.puts "Queue is empty - restarting queue."
        build_queue_urls()
    end
    schedule_work()

    {:noreply, queue}
  end

  def process({:page_link, url}, queue) do
    IO.puts "Fetching URL: #{url}"
    queue =
      url
      |> Connection.fetch
      |> fetch_torrent_link(queue)

    queue
  end

  def process({:torrent_link, url}, queue) do
    IO.puts "Fetching #{url}"
    data =
      url
      |> Connection.fetch
      |> EZTVParser.extract_torrent_data

    # Must save the data in the database
    IO.inspect data

    queue
  end

  defp fetch_torrent_link(body, queue) do
    body
    |> EZTVParser.torrent_links
    |> reduce_links(queue)
  end

  defp reduce_links(torrent_links, queue) do
    Enum.reduce(torrent_links, queue, fn link, queue ->
      :queue.in({:torrent_link, link}, queue)
    end)
  end

  defp build_queue_urls do
    EZTVParser.paginated_links |> :queue.from_list
  end
end
