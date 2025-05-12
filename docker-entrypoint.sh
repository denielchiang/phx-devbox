#!/bin/bash
set -e

echo "Starting docker-entrypoint.sh..."

# Check if Phoenix version is provided
if [ -z "$PHOENIX_VERSION" ]; then
  echo "Warning: Phoenix version not specified. If you need to use Phoenix, please specify the version using the -v option."
  HAS_PHOENIX=false
else
  HAS_PHOENIX=true
fi

# Display installed Elixir and Erlang versions
elixir --version

# Ensure Hex and Rebar are installed
echo "Ensuring Hex and Rebar are installed..."
mix local.hex --force
mix local.rebar --force

# Only install Phoenix if a version was provided
if [ "$HAS_PHOENIX" = true ]; then
  echo "Installing Phoenix $PHOENIX_VERSION..."
  # Check if it's an incomplete RC version number
  if [[ "$PHOENIX_VERSION" == *"-rc"* && ! "$PHOENIX_VERSION" == *"."* ]]; then
    echo "Warning: Using incomplete RC version number, trying $PHOENIX_VERSION.3"
    PHOENIX_VERSION="$PHOENIX_VERSION.3"
    echo "Installing corrected version: $PHOENIX_VERSION"
  fi
  mix archive.install --force hex phx_new $PHOENIX_VERSION
fi

echo "Initialization complete, preparing to execute command: $@"

# Create .tool-versions file when necessary
if [ -n "$ERLANG_VERSION" ] || [ -n "$ELIXIR_VERSION" ]; then
  echo "Creating .tool-versions file to record used versions..."
  # Use fixed versions to avoid errors
  CURRENT_ERLANG="27.3.3"
  CURRENT_ELIXIR="1.18.3"
  echo "erlang $CURRENT_ERLANG" > .tool-versions
  echo "elixir $CURRENT_ELIXIR" >> .tool-versions
  echo "Created .tool-versions file with versions: Erlang $CURRENT_ERLANG, Elixir $CURRENT_ELIXIR"
fi

# Check if there are commands to run
if [ "$#" -eq 0 ]; then
  echo "No command provided, starting bash shell"
  # If no command is provided, start a bash shell
  exec bash
fi

# Special command handling
if [ "$WATCHDOG_ENABLED" = true ] && [ "$1" = "mix" ] && [ "$2" = "phx.server" ]; then
  echo "Enabling live code reload..."
  exec mix phx.server
fi

# Special handling for phx.new command
if [ "$1" = "phx.new" ]; then
  echo "Using mix phx.new to create a new project"
  shift
  exec mix phx.new "$@"
fi

# Execute the passed command
echo "Executing command: $@"
exec "$@"
