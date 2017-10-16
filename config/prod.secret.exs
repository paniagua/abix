use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :abix, Abix.Endpoint,
  secret_key_base: "WCjzpsiIUFvwl8RmGvNTC0+00yXtbZKp2PGbdHvGjnOLkx+JmY54KM1MABif3wtI"

# Configure your database
config :abix, Abix.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "messenger",
  password: "salemove",
  database: "messenger",
  hostname: "postgres",
  pool_size: 15
