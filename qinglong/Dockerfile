# 使用 Debian 官方精简镜像
FROM debian:stable-slim

# 环境变量配置
ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai \
    NODE_OPTIONS=--max_old_space_size=16384 \
    CHROME_BIN=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/lib/chromium/chromedriver \
    PLAYWRIGHT_BROWSERS_PATH=/usr/lib/chromium

# 设置工作目录
WORKDIR /ql

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 基础工具链
    curl \
    wget \
    git \
    ca-certificates \
    sudo \
    # Python 环境
    python3 \
    python3-pip \
    python3-venv \
    # Chromium 核心依赖
    chromium \
    chromium-driver \
    # 无头模式依赖
    xvfb \
    # 中文字体支持
    fonts-noto-cjk \
    fonts-wqy-microhei \
    # 浏览器依赖库
    libgbm1 \
    libxshmfence1 \
    libasound2 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    # Node.js 环境
    npm \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # 兼容性符号链接
    && ln -s /usr/lib/chromium/chromedriver /usr/bin/chromedriver \
    && ln -s /usr/bin/chromium /usr/bin/google-chrome

# 配置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装 Python 依赖
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    selenium==4.* \
    undetected-chromedriver==3.* \
    webdriver-manager==4.* \
    pyvirtualdisplay==3.* \
    playwright==1.* \
    requests-html==0.10.* \
    qinglong==2.* \
    # 青龙官方依赖
    cryptography==41.* \
    telethon==1.* \
    python-dotenv==1.* \
    aiohttp==3.*

# 安装 Playwright 浏览器
RUN playwright install chromium

# 克隆青龙仓库 (示例仓库，可替换)
ARG QL_REPO=https://github.com/whyour/qinglong.git
ARG QL_BRANCH=develop
RUN git clone -b $QL_BRANCH --depth 1 $QL_REPO . \
    && npm install -g pnpm \
    && pnpm install --prod

# 暴露端口
EXPOSE 5700

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -fs http://localhost:5700/api/health || exit 1

# 启动命令
CMD ["/ql/sample/docker-entrypoint.sh"]