defmodule KeyValue.Handoff do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    register()
    :net_kernel.monitor_nodes(true)
    check_neighbors()

    {:ok, []}
  end

  def create_update_map(map_name, map) do
    DeltaCrdt.mutate(get_self(), :add, [map_name, map])
  end

  def get_self() do
    case Horde.Registry.lookup(KeyValue.Registry, "#{Node.self()}_crdt") do
      [{_, pid}] -> pid
      _ -> nil
    end
  end

  def read_map(map_name) do
    DeltaCrdt.read(get_self()) |> Map.get(map_name)
  end

  def remove_map(map_name) do
    DeltaCrdt.mutate(get_self(), :remove, [map_name])
  end

  def whereis(node_name) do
    case Horde.Registry.lookup(KeyValue.Registry, "#{node_name}_crdt") do
      [{_, pid}] -> pid
      _ -> nil
    end
  end

  defp check_neighbors() do
    node_count =
      Node.list()
      |> Enum.count()

      case node_count do
        0 -> IO.puts("No neighbor nodes to connect")
        _ -> Process.send_after(self(), {:retry_add_neighbors, 0}, 100)
    end
  end

  defp register do
    {:ok, crdt} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap)
    Horde.Registry.register(KeyValue.Registry, "#{node()}_crdt", crdt)
  end

  def handle_info({:nodeup, node}, state) do
    handle_info({:retry_nodeup, node, 0}, state)
  end

  def handle_info({:retry_nodeup, node, count}, state) do
    case __MODULE__.whereis(node) do
      nil ->
        IO.puts("Can't connect to app on node #{node}, retry = #{count}")
        Process.send_after(self(), {:retry_nodeup, node, count + 1}, 500)
      pid ->
        IO.puts("Adding new neighbor node CRDT #{inspect(node)}")
        DeltaCrdt.add_neighbours(get_self(), [pid])
    end

    {:noreply, state}
  end

  def handle_info({:retry_add_neighbors, count}, state) do
    neighbors =
      Node.list()
      |> Enum.map(fn node -> __MODULE__.whereis(node) end)

    case Enum.filter(neighbors, fn pid -> pid == nil end) do
      [] ->
        IO.puts("Node is up, adding neighbor CRDT in node(s) #{inspect(Node.list())}")
        DeltaCrdt.add_neighbours(get_self(), neighbors)
      _ ->
        IO.puts("Can't add neighboring node CRDT, retry = #{count}")
        Process.send_after(self(), {:retry_add_neighbors, count + 1}, 500)
    end

    {:noreply, state}
  end

  def handle_info({:nodedown, _node}, state), do: {:noreply, state}

end
