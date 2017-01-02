defmodule Xtorrent.Producers.C do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [Xtorrent.Producers.B]}
  end

  def handle_events(events, _from, state) do
    IO.inspect {self(), events, state}

    # As a consumer we never emit events
    {:noreply, [], state}
  end
end
