defmodule KeyValue.Cache do
  def start_link() do
    IO.puts("Starting KV Supervisor")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def server_process(name) do
    existing_process(name) || new_process(name)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # def local_swarm_processes() do
  #   Swarm.registered
  #   |> Enum.filter(fn {_, pid} -> node(pid) == node() end)
  # end

  # def local_swarm_count() do
  #   Swarm.registered
  #   |> Stream.map(fn {_, pid} -> pid end)
  #   |> Stream.filter(fn pid -> node(pid) == node() end)
  #   |> Enum.count()
  # end

  defp existing_process(name) do
    KeyValue.Worker.whereis(name)
  end

  defp new_process(name) do
    case DynamicSupervisor.start_child(__MODULE__, {KeyValue.Worker, name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
