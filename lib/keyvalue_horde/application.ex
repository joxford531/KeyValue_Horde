defmodule KeyValue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {
        Cluster.Supervisor,
        [Application.get_env(:libcluster, :topologies), [name: __MODULE__.ClusterSupervisor]]
      },
      {Horde.Registry, [name: KeyValue.Registry, keys: :unique]},
      {Horde.Supervisor, [name: KeyValue.HordeSupervisor, strategy: :one_for_one]},
      {KeyValue.Connector, []},
      {KeyValue.Handoff, []}
    ]
    opts = [strategy: :one_for_one, name: KeyValue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def create_maps() do
    1..50
    |> Enum.each(fn num -> KeyValue.Cache.server_process("map #{num}") end)
  end

  def put_maps() do
    1..50
    |> Enum.each(fn num -> KeyValue.Worker.put("map #{num}", "#{num} item", :rand.uniform(1_000_000)) end)
  end
end
