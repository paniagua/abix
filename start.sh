#!/bin/sh
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
brunch build --production

mix phx.digest

# Custom tasks (like DB migrations)
MIX_ENV=prod mix ecto.migrate

# Finally run the server
PORT=4000 MIX_ENV=prod mix phx.server