defmodule Xtorrent.Producers.A do
  alias Experimental.GenStage
  use GenStage

  def start_link(initial \\ []) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(links) do
    {:producer, links}
  end

  def handle_demand(demand, state) do
    urls = Xtorrent.Eztv.Parser.paginated_links
    pages = urls |> Enum.map(fn link -> download(link) end)

    {:noreply, pages, state}
  end

  defp download(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Error: #{url} is 404."
        :error
      {:error, %HTTPoison.Error{reason: _}} ->
        IO.puts "Error: #{url} just ain't workin."
        :error
    end
  end
end
