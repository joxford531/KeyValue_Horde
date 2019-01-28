defmodule KeyvalueGlobalTest do
  use ExUnit.Case
  doctest KeyvalueGlobal

  test "greets the world" do
    assert KeyvalueGlobal.hello() == :world
  end
end
