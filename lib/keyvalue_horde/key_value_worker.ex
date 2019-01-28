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
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
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
end
