#!/usr/bin/env bash
echo
echo "正在安装wget unzip ..."
echo
if type wget unzip >/dev/null 2>&1; then
    echo "wget unzip 已安装 🎉  "
    echo
else
    echo "wget unzip 未安装"
    if [[ -f /etc/redhat-release ]]; then
        yum install wget unzip -y
    else
        apt install wget unzip -y
    fi
fi
echo
if type node >/dev/null 2>&1; then
    echo "已安装 Node.js 🎉"
    echo
    node -v
    npm -v
else
    echo "正在安装 Node.js..."

    if type apt >/dev/null 2>&1; then
        curl -sL https://deb.nodesource.com/setup_current.x | -E bash -
        apt-get install -y nodejs
    elif type yum >/dev/null 2>&1; then
        curl -sL https://rpm.nodesource.com/setup_current.x | -E bash -
        yum install -y nodejs
    elif type brew >/dev/null 2>&1; then
        brew install node
    else
        echo "不支持的操作系统或找不到适用的包管理器！"
        exit 1
    fi

    echo
    echo "Node.js 安装完成！"
    echo
    node -v
    npm -v
fi

if ! type npm >/dev/null 2>&1; then
    echo
    echo "npm 未安装，正在安装..."
    echo
    if command -v apt >/dev/null 2>&1; then
        apt update
        apt install -y npm
    elif command -v yum >/dev/null 2>&1; then
        yum update
        yum install -y npm
    else
        echo
        echo "不支持该系统的包管理器"
        exit 1
    fi
    echo
    echo "npm 安装完成！"
else
    echo
    echo "npm 已经安装"
fi
echo
echo
if type pm2 </dev/null >/dev/null 2>&1; then
    echo "已安装pm2 🎉 "
    echo
else
    echo "正在安装pm2"
    npm install pm2 -g
fi

if [[ ! -d /root/snell ]]; then
    echo "创建文件夹"
    echo
    mkdir -p /root/snell
else
    echo "文件夹已存在 🎉 "
    cd /root/snell
fi

OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
    OS_ARCH="amd64"
    echo
    echo "当前系统架构为 ${OS_ARCH}"
    echo
elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "aarch64" ]]; then
    OS_ARCH="aarch64"
    echo
    echo "当前系统架构为 ${OS_ARCH}"
else
    OS_ARCH="amd64"
    echo
    echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi
echo
echo mkdir -p /root/snell 
echo
echo "正在下载snell..."
echo
if [[ -f /root/snell/snell-server ]]; then
    echo "snell-server已存在 🎉 "
    echo
else
    echo "snell-server不存在 下载中..."
    echo
    wget https://github.com/Slotheve/Snell/raw/main/snell-server-v4.0.1-linux-${OS_ARCH}.zip -O snell.zip >/dev/null 2>&1
    echo
    echo "正在解压snell..."
    echo
    
    rm -rf snell-server && unzip -o snell.zip && rm -f snell.zip && chmod +x snell-server
fi

if [[ -f /root/snell/snell-server.conf ]]; then
    echo "snell-server.conf已存在 🎉 "
    echo
else
    echo
    echo "snell-server.conf不存在 创建中..."
    
    cd /root/snell
    echo
    read -p "请输入snell-server的端口:" port
    echo

    cat <<EOF >/root/snell/snell-server.conf

[snell-server]
listen = 0.0.0.0:${port}
psk = DsU0x9afoOKLoWI1kUYnlxj6tv3YDef
ipv6 = false
obfs = http

EOF
fi
echo
if [[ $(pm2 list | grep snell-server | wc -l) -gt 0 ]]; then
    echo "snell-server已启动 🎉 "
    echo
else
    echo "正在启动snell..."
    cd /root/snell
    pm2 start ./snell-server -- -c snell-server.conf && pm2 save
fi
echo
echo "正在读取snell配置文件..."
echo
cat /root/snell/snell-server.conf
echo
echo "正在读取snell运行日志..."
echo
pm2 ls && pm2 log snell-server --lines 10 --raw --nostream
echo
echo "surge 配置示例 🎉。"
echo
echo "=============================="
echo
echo "snell = snell,$(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}'),"$(cat /root/snell/snell-server.conf | grep "listen" | awk -F ":" '{print $2}' | sed 's/ //g')",psk=$(cat /root/snell/snell-server.conf | grep "psk" | awk -F "=" '{print $2}' | sed 's/ //g'),obfs=$(cat /root/snell/snell-server.conf | grep "obfs" | awk -F "=" '{print $2}' | sed 's/ //g'),version=4, reuse=true"
echo
echo "=============================="
echo
echo " snell 安装完成 🎉 "
echo
