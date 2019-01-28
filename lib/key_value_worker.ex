defmodule KeyValue.Worker do
  use GenServer

  def start_link(name) do
    IO.puts("Starting KV-#{name}")
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  def put(name, key, value) do
    GenServer.cast(via_tuple(name), {:put, key, value})
  end

  def get(name, key) do
    GenServer.call(via_tuple(name), {:get, key})
  end

  def whereis(name) do
    case Horde.Registry.lookup(KeyValue.Registry, name) do
      {pid, _} -> pid
      _ -> nil
    end
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {KeyValue.Registry, name}}
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, store) do
    {:noreply, Map.put(store, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, store) do
    {:reply, Map.get(store, key), store}
  end

  def handle_cast({:swarm, :end_handoff, previous_state}, _state) do
    {:noreply, previous_state}
  end

  def handle_cast({:swarm, :resolve_conflict, other_state}, _state) do
    {:noreply, other_state}
  end

  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state}
  end

  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end
