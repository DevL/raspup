defmodule ClusterUpTest do
  use ExUnit.Case
  doctest ClusterUp

  @nodes [:"bramble@red.local", :"bramble@green.local", :"bramble@blue.local"]

  describe "cluster" do
    defmodule FakeConnect do
      def connect(:"bramble@green.local"), do: false
      def connect(_node_name), do: true
    end

    test "attempts to connect to a list of nodes" do
      assert ClusterUp.cluster(@nodes, FakeConnect) == %{
               connected: [:"bramble@red.local", :"bramble@blue.local"],
               not_found: [:"bramble@green.local"]
             }
    end
  end

  describe "nodes" do
    test "reads a node list from file" do
      assert ClusterUp.nodes("test/fixtures/nodes.txt") == @nodes
    end
  end
end
