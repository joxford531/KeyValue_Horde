defmodule KeyValue.Handoff do

  def register do
    {:ok, crdt} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap)
    Horde.Registry.register(KeyValue.Registry, "#{node()}_crdt", crdt)
  end

  def whereis(node_name) do
    case Horde.Registry.lookup(KeyValue.Registry, "#{node_name}_crdt") do
      [{pid, _}] -> pid
      _ -> nil
    end
  end
end
