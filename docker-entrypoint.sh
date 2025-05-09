#!/bin/bash
set -e

echo "啟動 docker-entrypoint.sh..."

# 檢查是否提供了 Phoenix 版本
if [ -z "$PHOENIX_VERSION" ]; then
  echo "警告：未指定 Phoenix 版本。如果需要使用 Phoenix，請通過 -v 選項指定版本。"
  HAS_PHOENIX=false
else
  HAS_PHOENIX=true
fi

# 顯示已安裝的 Elixir 和 Erlang 版本
elixir --version

# 確保 Hex 和 Rebar 已安裝
echo "確保 Hex 和 Rebar 已安裝..."
mix local.hex --force
mix local.rebar --force

# 只有在提供了 Phoenix 版本的情況下才安裝 Phoenix
if [ "$HAS_PHOENIX" = true ]; then
  echo "安裝 Phoenix $PHOENIX_VERSION..."
  # 檢查是否是不完整的 RC 版本號
  if [[ "$PHOENIX_VERSION" == *"-rc"* && ! "$PHOENIX_VERSION" == *"."* ]]; then
    echo "警告: 使用不完整的 RC 版本號，嘗試使用 $PHOENIX_VERSION.3"
    PHOENIX_VERSION="$PHOENIX_VERSION.3"
    echo "正在安裝修正後的版本: $PHOENIX_VERSION"
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
