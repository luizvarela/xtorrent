defmodule Xtorrent do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
       worker(Xtorrent.Producers.A, []),
       worker(Xtorrent.Producers.B, []),
       worker(Xtorrent.Producers.C, []),
    ]

    opts = [strategy: :one_for_one, name: Xtorrent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
