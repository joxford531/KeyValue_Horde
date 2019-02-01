defmodule KeyValue.Worker do
  use GenServer

  def child_spec(name) do
    %{
      id: "#{__MODULE__}_#{name}",
      start: {__MODULE__, :start_link, [name]}
    }
  end

  def start_link(name) do
    IO.puts("Starting KV-#{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def put(name, key, value) do
    GenServer.cast(via_tuple(name), {:put, key, value})
  end

  def get(name, key) do
    GenServer.call(via_tuple(name), {:get, key})
  end

  def whereis(name) do
    case Horde.Registry.lookup(KeyValue.Registry, {__MODULE__, name}) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {KeyValue.Registry, {__MODULE__, name}}}
  end

  defp get_cached_map(name) do
    KeyValue.Handoff.read_map(name)
  end

  @impl GenServer
  def init(name) do
    case get_cached_map(name) do
      nil ->
        KeyValue.Handoff.create_update_map(name, %{})
        {:ok, {name, %{}}}
      map -> {:ok, {name, map}}
    end
  end

  @impl GenServer
  def handle_cast({:put, key, value}, {name, map}) do
    updated_map = Map.put(map, key, value)
    KeyValue.Handoff.create_update_map(name, updated_map)
    {:noreply, {name, updated_map}}
  end

  @impl GenServer
  def handle_call({:get, key}, _, {name, map}) do
    {:reply, Map.get(map, key), {name, map}}
  end
end
