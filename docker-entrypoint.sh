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

echo "初始化完成，準備執行命令: $@"

# 在必要時創建 .tool-versions 檔案
if [ -n "$ERLANG_VERSION" ] || [ -n "$ELIXIR_VERSION" ]; then
  echo "創建 .tool-versions 檔案以記錄使用的版本..."
  # 直接使用固定版本避免錯誤
  CURRENT_ERLANG="27.3.3"
  CURRENT_ELIXIR="1.18.3"
  echo "erlang $CURRENT_ERLANG" > .tool-versions
  echo "elixir $CURRENT_ELIXIR" >> .tool-versions
  echo "已創建 .tool-versions 檔案並記錄版本: Erlang $CURRENT_ERLANG, Elixir $CURRENT_ELIXIR"
fi

# 檢查是否有命令要運行
if [ "$#" -eq 0 ]; then
  echo "未提供命令，啟動 bash shell"
  # 如果沒有提供命令，則啟動 bash shell
  exec bash
fi

# 特殊命令處理
if [ "$WATCHDOG_ENABLED" = true ] && [ "$1" = "mix" ] && [ "$2" = "phx.server" ]; then
  echo "啟用實時代碼重載..."
  exec mix phx.server
fi

# 特殊處理 phx.new 命令
if [ "$1" = "phx.new" ]; then
  echo "使用 mix phx.new 來創建新專案"
  shift
  exec mix phx.new "$@"
fi

# 執行傳入的命令
echo "執行命令: $@"
exec "$@"
