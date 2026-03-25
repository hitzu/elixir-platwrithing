defmodule PhoenixPlaywrithing.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixPlaywrithingWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_playwrithing, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixPlaywrithing.PubSub},
      PhoenixPlaywrithingWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: PhoenixPlaywrithing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PhoenixPlaywrithingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
