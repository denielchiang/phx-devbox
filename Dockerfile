# Use official Elixir Docker image
# Using Elixir 1.18.3 and Erlang/OTP 27
FROM elixir:1.18.3-otp-27

# Set timezone
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary tools
RUN apt-get update -y && apt-get install -y \
    build-essential \
    inotify-tools \
    git \
    postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Set up file system monitoring
ENV WATCHDOG_ENABLED=true

# Install necessary Elixir packages
RUN mix local.hex --force && \
    mix local.rebar --force

# Create directories and set permissions for non-root users to install packages
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
