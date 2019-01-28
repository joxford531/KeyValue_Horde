defmodule KeyValue.Cache do
  def server_process(name) do
    existing_process(name) || new_process(name)
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
    case Horde.Supervisor.start_child(KeyValue.HordeSupervisor, {KeyValue.Worker, name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
