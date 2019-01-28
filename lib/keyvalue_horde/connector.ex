defmodule KeyValue.Connector do
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    connect_supervisor()
    connect_registry()
    # Horde.Supervisor.start_child(KeyValue.HordeSupervisor, KeyValue.Cache)
  end

  defp connect_supervisor do
    Node.list()
    |> Enum.each(fn node ->
      Horde.Cluster.join_hordes(KeyValue.HordeSupervisor, {KeyValue.HordeSupervisor, node})
    end)
  end

  defp connect_registry do
    Node.list()
    |> Enum.each(fn node ->
      Horde.Cluster.join_hordes(KeyValue.Registry, {KeyValue.Registry, node})
    end)
  end
end
