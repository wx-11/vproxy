#!/bin/bash

echo

handle_error() {
    echo "错误: $1" >&2
    exit 1
}

if [ "$(id -u)" -ne 0 ]; then
  handle_error "错误: 请使用 root 权限运行此脚本"
  exit 1
fi

BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           进入 vproxy 安装脚本             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"

echo 
cd /tmp || exit

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

echo -e "即将下载 $ARCH-$OS 系统安装包 $FILENAME ... \n$download_url"
curl -L -o "$FILENAME" "$download_url" || handle_error "下载失败"
tar -xzf "$FILENAME" || handle_error "解压失败"
echo

read -rp "是否将程序安装到 /bin/vproxy ? (全局变量使用 y/n): " install_choice
if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    if [ -f vproxy ]; then
        mv vproxy /bin/vproxy || handle_error "安装失败，请检查权限"
        echo -e "安装完成: /bin/vproxy\n版本: $(vproxy --version)\n文档: https://github.com/wx-11/vproxy/blob/main/zh_cn.md"
    else
        handle_error "找不到可执行文件"
    fi
else
    if [ -f vproxy ]; then
        mv vproxy /root/vproxy || handle_error "安装失败，请检查权限"
        echo -e "安装完成: 需要带路径使用 /root/vproxy\n版本: $(vproxy --version)\n文档: https://github.com/wx-11/vproxy/blob/main/zh_cn.md"
    else
        handle_error "找不到可执行文件"
    fi
fi

echo
rm -f "$FILENAME"
