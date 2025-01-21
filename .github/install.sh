#!/bin/bash

# 设置工作目录
cd /tmp || exit

# 定义错误处理函数
handle_error() {
    echo "错误: $1"
    exit 1
}

echo "正在获取最新版本信息..."
release_info=$(curl -s "https://api.github.com/repos/wx-11/vproxy/releases/latest") || handle_error "无法获取版本信息"
tag=$(echo "$release_info" | grep -oP '"tag_name": "\K(.*?)(?=")') || handle_error "无法解析版本标签"
version=${tag#v}

ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

FILENAME="vproxy-$version-"
case "$ARCH-$OS" in
    "aarch64-darwin")  FILENAME+="aarch64-apple-darwin" ;;
    "aarch64-linux")   FILENAME+="aarch64-unknown-linux-musl" ;;
    "arm-linux")       FILENAME+="arm-unknown-linux-musleabihf" ;;
    "armv7l-linux")    FILENAME+="armv7-unknown-linux-musleabihf" ;;
    "i686-windows")    FILENAME+="i686-pc-windows-gnu" ;;
    "i686-linux")      FILENAME+="i686-unknown-linux-musl" ;;
    "x86_64-darwin")   FILENAME+="x86_64-apple-darwin" ;;
    "x86_64-windows")  FILENAME+="x86_64-pc-windows-gnu" ;;
    "x86_64-linux")    FILENAME+="x86_64-unknown-linux-musl" ;;
    *) handle_error "不支持的系统架构: $ARCH-$OS" ;;
esac
FILENAME+=".tar.gz"

download_url="https://github.com/wx-11/vproxy/releases/download/$tag/$FILENAME"

echo "正在下载 $ARCH-$OS 系统安装包 $FILENAME ... $download_url"
curl -L -o "$FILENAME" "$download_url" || handle_error "下载失败"
tar -xzf "$FILENAME" || handle_error "解压失败"

# 询问用户是否要安装
read -rp "是否将程序安装到 /bin/vproxy? (y/n): " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    if [ -f vproxy ]; then
        sudo mv vproxy /bin/vproxy || handle_error "安装失败，请检查权限"
        echo "安装完成: /bin/vproxy 版本: $(vproxy --version)"
    else
        handle_error "找不到可执行文件"
    fi
else
    echo "已取消安装"
fi

rm -f "$FILENAME"
