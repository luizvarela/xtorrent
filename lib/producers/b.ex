defmodule Xtorrent.Producers.B do
  alias Experimental.GenStage
  use GenStage

  require Integer

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [Xtorrent.Producers.A]}
  end

  def handle_events(events, _from, state) do
    torrent_links = Enum.map(events, fn e -> Xtorrent.Eztv.Parser.torrent_links(e)end)
    {:noreply, torrent_links, state}
  end
end
