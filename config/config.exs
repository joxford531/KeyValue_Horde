# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :libcluster,
  topologies: [
    example: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [:"debug@127.0.0.1", :"a@127.0.0.1", :"b@127.0.0.1", :"c@127.0.0.1"]]
    ]
  ]
