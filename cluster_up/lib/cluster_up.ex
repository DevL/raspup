defmodule ClusterUp do
  @moduledoc """
  Documentation for `ClusterUp`.
  """

  @doc """
  List the nodes that should be part of the cluster.
  """
  def nodes(nodes_file \\ "nodes.txt") do
    File.read!(nodes_file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_atom/1)
  end

  def cluster(nodes, connector \\ Node) do
    nodes
    |> Enum.group_by(connect_using(connector))
  end

  defp connect_using(connector) do
    fn node_name -> node_name |> connector.connect() |> connection_result() end
  end

  defp connection_result(true), do: :connected
  defp connection_result(false), do: :not_found
end
