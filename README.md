# Phoenix Docker Development Environment

This is a Docker environment for Elixir Phoenix local development. It allows you to:
- Use Elixir 1.18.3 and Erlang/OTP 27
- Specify any Phoenix framework version
- Create new projects in a specified path
- Use your local PostgreSQL database
- Run all mix commands supported by Phoenix
- **No need to install Elixir or Erlang locally**

## Prerequisites

- Docker and Docker Compose
- Locally installed PostgreSQL (via `brew install postgresql@16` or other version)
- Ensure PostgreSQL service is started (`brew services start postgresql@16`)

## Usage Instructions

### Full Usage of the phx.sh Script

```bash
# Basic syntax
phx [options] command [command parameters]

# Available options
#  --path PATH       Specify project path, default is current directory
#  --phx VERSION     Specify Phoenix version, e.g. 1.8.0-rc.3

# Special commands
#  new APP_NAME      Create a new Phoenix project
#  bash              Enter the container's bash terminal
#  iex               Start Elixir interactive console
#  iex.phx           Start Elixir interactive console and load Phoenix application

# Any other commands will be passed to mix, for example:
#  ecto.create       Create database
#  ecto.migrate      Run migrations
#  deps.get          Install dependencies
#  phx.server        Start Phoenix server
#  phx.gen.html      Generate HTML resources
```

### Creating a New Phoenix Project

```bash
# Create a new project in the default directory, the system will prompt you to enter the Phoenix version
phx new my_app

# Specify Phoenix version
phx --phx 1.8.0-rc.3 new my_app

# Create a new project in a specified path
phx --path /specified/path --phx 1.8.0-rc.3 new my_app --live
```

### Special Notes
When you only run `phx new my_app` without specifying a Phoenix version:

1. The script will prompt you to enter the Phoenix version to use
2. If you enter a valid version number, the project will be successfully created
3. If you press Enter without entering a version number, the script will error and exit
4. Regardless of which project you create, the following versions are fixed:
   - Elixir: 1.18.3
   - Erlang/OTP: 27
   - Only the Phoenix version is variable, with a default of 1.7.10

### Running Existing Projects

```bash
# Run an existing Phoenix project in a specified path
phx --path /path/to/your/project phx.server

# Create database
phx --path /path/to/your/project ecto.create

# Run migrations
phx --path /path/to/your/project ecto.migrate

# Install dependencies
phx --path /path/to/your/project deps.get

# Start interactive Elixir web server
phx --path /path/to/your/project iex.phx
```

### Notes

1. The first time you run a project, it will automatically download Tailwind and other frontend resources, which may take some time
2. Make sure the PostgreSQL service is running, otherwise the project will not be able to connect to the database
3. You can execute bash inside the container for advanced operations:
   ```bash
   phx --path /path/to/your/project bash
   ```
4. All files will be stored in your local file system and can be edited with your preferred editor
