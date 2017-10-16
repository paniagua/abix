# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :abix,
  ecto_repos: [Abix.Repo]

# Configures the endpoint
config :abix, Abix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Zb3iG6WvJ+j8t8ztyjPu79gRvHiX9qkMDmzaA7GoVbot+3BTp3VCS5NR5wIIy01Q",
  render_errors: [view: Abix.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Abix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  backends: [:console]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
