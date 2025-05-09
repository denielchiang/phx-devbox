# Phoenix Docker 開發環境

這是一個用於 Elixir Phoenix 本地開發的 Docker 環境。它允許您：
- 使用 Elixir 1.18.3 和 Erlang/OTP 27
- 指定任何 Phoenix 框架版本
- 在指定路徑創建新專案
- 使用您本地的 PostgreSQL 資料庫
- 運行所有 Phoenix 支援的 mix 命令
- **不需要在本機安裝 Elixir 或 Erlang**

## 前置需求

- Docker 與 Docker Compose
- 本地安裝的 PostgreSQL（通過 `brew install postgresql@16` 或其他版本）
- 確保 PostgreSQL 服務已啟動（`brew services start postgresql@16`）

## 使用說明

### phx.sh 腳本的完整用法

```bash
# 基本語法
./phx.sh [選項] 命令 [命令參數]

# 可用選項
#  --path PATH       指定項目路徑，預設為目前目錄
#  --phx VERSION     指定 Phoenix 版本，例如 1.8.0-rc.3

# 特殊命令
#  new APP_NAME      創建新的 Phoenix 專案
#  bash              進入容器的 bash 終端
#  iex               啟動 Elixir 互動式控制台
#  iex.phx           啟動 Elixir 互動式控制台並加載 Phoenix 應用

# 任何其他命令會被傳送到 mix，例如：
#  ecto.create       創建資料庫
#  ecto.migrate      運行遷移
#  deps.get          安裝依賴
#  phx.server        啟動 Phoenix 伺服器
#  phx.gen.html      產生 HTML 資源
```

### 創建新的 Phoenix 專案

```bash
# 在預設目錄創建新項目，系統會提示您輸入 Phoenix 版本
./phx.sh new my_app

# 指定 Phoenix 版本
./phx.sh --phx 1.8.0-rc.3 new my_app

# 在指定路徑創建新專案
./phx.sh --path /指定路徑 --phx 1.8.0-rc.3 new my_app --live
```

### 特別說明
當您只運行 `./phx.sh new my_app` 而不指定 Phoenix 版本時：

1. 腳本會提示您輸入要使用的 Phoenix 版本
2. 如果您輸入有效的版本號，專案會成功創建
3. 如果您按下 Enter 而不輸入版本號，腳本會報錯並退出
4. 無論您創建任何項目，以下版本都是固定的：
   - Elixir: 1.18.3
   - Erlang/OTP: 27
   - 只有 Phoenix 版本是可變的，預設為 1.7.10

### 運行現有專案

```bash
# 在指定路徑運行已存在的 Phoenix 專案
./phx.sh --path /您專案的路徑 phx.server

# 創建資料庫
./phx.sh --path /您專案的路徑 ecto.create

# 運行遷移
./phx.sh --path /您專案的路徑 ecto.migrate

# 安裝依賴
./phx.sh --path /您專案的路徑 deps.get

# 啟動互動式 Elixir 網頁伺服器
./phx.sh --path /您專案的路徑 iex.phx
```

### 注意事項

1. 第一次運行專案時，它會自動下載 Tailwind 和其他前端資源，可能需要一些時間
2. 確保 PostgreSQL 服務已啟動，否則專案將無法連接到資料庫
3. 您可以在容器內部執行 bash 以進行進階操作：
   ```bash
   ./phx.sh --path /您專案的路徑 bash
   ```
4. 所有的檔案會被儲存在您的本地檔案系統中，並且可以用您喜歡的編輯器編輯
