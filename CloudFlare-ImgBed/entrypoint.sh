#!/bin/bash

# 设置哪吒默认环境变量
export NEZHA_SERVER=${NEZHA_SERVER:-''}
export NEZHA_PORT=${NEZHA_PORT:-''}
export NEZHA_KEY=${NEZHA_KEY:-''}
export NEZHA_ARGS=${NEZHA_ARGS:-'--disable-command-execute --disable-auto-update'}


#安装所需依赖
npm install

# 创建 wrangler.toml 文件
cat <<EOF > /app/wrangler.toml
name = "${name}"
compatibility_date = "${compatibility_date}"

[vars]
ModerateContentApiKey = "${ModerateContentApiKey}"
AllowRandom = "${AllowRandom}"
BASIC_USER = "${BASIC_USER}"
BASIC_PASS = "${BASIC_PASS}"
TG_BOT_TOKEN = "${TG_BOT_TOKEN}"
TG_CHAT_ID = "${TG_CHAT_ID}"
AUTH_CODE = "${AUTH_CODE}"
ALLOWED_DOMAINS = "${ALLOWED_DOMAINS}"
EOF
########################################################################################
#wrangler.toml变量说明
#ModerateContentApiKey: 用于过滤图片的ModerateContentApiKey
#AllowRandom: 是否允许随机获取图片
#BASIC_USER: 基本认证用户名
#BASIC_PASS: 基本认证密码
#TG_BOT_TOKEN: Telegram Bot Token
#TG_CHAT_ID: Telegram Chat ID
#AUTH_CODE: 用于上传图片的Auth Code
#ALLOWED_DOMAINS: 防盗链 访问域名限制
########################################################################################



# 配置文件路径
SUPERVISORD_CONFIG_PATH="/etc/supervisord.conf"

# 创建Supervisor配置文件
cat <<EOF > $SUPERVISORD_CONFIG_PATH
[supervisord]
nodaemon=true

[program:node_app]
command=npm run start
directory=/app/
autostart=true
autorestart=true
stderr_logfile=/var/log/node_app.err.log
stdout_logfile=/var/log/node_app.out.log

[program:nginx]
command=nginx -g 'daemon off;'  
autorestart=true
user=$(whoami)

EOF

# 如果设置了 Nezha 相关变量，添加 nezha-agent 到 Supervisor 配置
if [ -n "$NEZHA_SERVER" ] && [ -n "$NEZHA_PORT" ] && [ -n "$NEZHA_KEY" ]; then
  cat >> ${SUPERVISORD_CONFIG_PATH} << EOF
[program:nezha-agent]
command=nezha-agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_ARGS}
autostart=true
autorestart=true
EOF
else
  echo "NEZHA_SERVER, NEZHA_PORT, 或 NEZHA_KEY 未设置，跳过 nezha-agent 配置。"
fi


# 启动Supervisor
# 启动 Supervisor
echo "启动 supervisord 以管理服务..."
exec supervisord -n -c ${SUPERVISORD_CONFIG_PATH}