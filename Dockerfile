# 使用官方 Elixir Docker 映像
# 使用 Elixir 1.18.3 和 Erlang/OTP 27
FROM elixir:1.18.3-otp-27

# 設定時區
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安裝必要的工具
RUN apt-get update -y && apt-get install -y \
    build-essential \
    inotify-tools \
    git \
    postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 工作目錄
WORKDIR /app

# 設置文件系統監控
ENV WATCHDOG_ENABLED=true

# 安裝必要的 Elixir 套件
RUN mix local.hex --force && \
    mix local.rebar --force

# 創建目錄並設定權限以便非 root 用戶可以安裝套件
RUN mkdir -p /opt/mix/archives && \
    chmod -R 777 /opt/mix && \
    mkdir -p /opt/hex/packages/hexpm && \
    chmod -R 777 /opt/hex && \
    mkdir -p /root/.mix && \
    chmod -R 777 /root/.mix && \
    mkdir -p /root/.hex && \
    chmod -R 777 /root/.hex

# 設定 shell 使用 login
SHELL ["/bin/bash", "-l", "-c"]

# 在運行時腳本中嘗試不同的方法
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# 給予腳本執行權限
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 設定環境變數
ENV MIX_HOME=/opt/mix
ENV HEX_HOME=/opt/hex

# 設定入口點
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
