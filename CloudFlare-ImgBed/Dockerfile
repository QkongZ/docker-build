# 使用官方的 Node.js 镜像作为基础镜像
FROM node:14

# 设置工作目录
WORKDIR /app/

# 安装 安装必要的软件包
RUN apt-get update && apt-get --no-cache install -y git curl bash nginx su-exec supervisor \
    mkdir -p /var/run && chown -R nginx:nginx /var/run


# 克隆远程仓库代码
RUN git clone https://github.com/MarSeventh/CloudFlare-ImgBed.git ./ && ls -la



# 安装哪吒监控端
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/nezhahq/agent/releases/latest | jq -r .tag_name) && \
    #自动识别最新哪吒监控端版本并下载
    wget -O ./nezha-agent.zip "https://github.com/nezhahq/agent/releases/download/${LATEST_VERSION}/nezha-agent_linux_$(uname -m | sed "s#x86_64#amd64#; s#aarch64#arm64#").zip" && \
    unzip ./nezha-agent.zip && \
    rm -f ./nezha-agent.zip
# 移动 nezha-agent 到 /usr/local/bin 并确保可执行权限
RUN mv ./nezha-agent /usr/local/bin/nezha-agent && \
    chmod +x /usr/local/bin/nezha-agent


# 复制 Nginx 配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 入口脚本
COPY entrypoint.sh /entrypoint.sh
# 设置权限并运行入口脚本 (在这一步添加调试信息)
RUN chmod +x /entrypoint.sh && ls -la /entrypoint.sh && /entrypoint.sh version

# 安装项目依赖
#RUN npm install

# 设置环境变量
ARG ModerateContentApiKey
ARG BASIC_USER
ARG BASIC_PASS
ARG TG_BOT_TOKEN
ARG TG_CHAT_ID

ENV ModerateContentApiKey=${ModerateContentApiKey} \
    AllowRandom=true \
    BASIC_USER=${BASIC_USER} \
    BASIC_PASS=${BASIC_PASS} \
    TG_BOT_TOKEN=${TG_BOT_TOKEN} \
    TG_CHAT_ID=${TG_CHAT_ID}

# 暴露应用运行的端口
EXPOSE 80

# 设置容器启动命令
CMD [ "/entrypoint.sh" ]