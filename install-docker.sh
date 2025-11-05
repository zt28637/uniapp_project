#!/bin/bash

##############################################################################
# Docker + Docker Compose 一键安装脚本
# 支持 Ubuntu/Debian 和 CentOS/RHEL 系统
# 使用方法: bash install-docker.sh
##############################################################################

set -e  # 遇到错误立即退出

# 日志文件
LOG_FILE="/var/log/docker-install.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 清理函数
cleanup_on_error() {
    print_error "安装过程中出现错误，正在清理..."
    
    # 清理 APT 源配置
    rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null
    
    # 如果有部分安装的 Docker，尝试卸载
    if command -v docker &> /dev/null; then
        print_warn "检测到部分安装的 Docker，建议手动卸载"
    fi
    
    print_error "清理完成。请检查日志文件: $LOG_FILE"
}

# 注册错误清理函数
trap cleanup_on_error ERR
trap 'print_error "安装被中断"; exit 1' INT TERM

# 检测系统类型
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        print_info "检测到系统: $OS $OS_VERSION"
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    fi
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        SYSTEM_TYPE="ubuntu"
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "rocky" ]]; then
        SYSTEM_TYPE="centos"
    else
        print_error "不支持的系统类型: $OS"
        exit 1
    fi
}

# 检查是否已安装 Docker
check_docker_installed() {
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        print_warn "检测到已安装 Docker: $DOCKER_VERSION"
        read -p "是否要重新安装? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "跳过 Docker 安装"
            exit 0
        fi
    fi
}

# 安装 Docker (Ubuntu/Debian)
install_docker_ubuntu() {
    print_info "开始安装 Docker (Ubuntu/Debian)..."
    
    # 预清理：删除可能存在的旧配置
    print_info "清理旧配置..."
    rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null
    rm -f /etc/apt/keyrings/docker.gpg 2>/dev/null
    apt-get clean 2>/dev/null || true
    
    # 更新系统包
    print_info "更新系统包..."
    apt-get update
    
    # 安装必要的工具
    print_info "安装必要的工具..."
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # 添加 Docker 官方 GPG 密钥
    print_info "添加 Docker 官方 GPG 密钥..."
    install -m 0755 -d /etc/apt/keyrings
    
    # 下载 GPG 密钥（带重试机制）
    MAX_RETRIES=3
    RETRY_COUNT=0
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if curl -fsSL --max-time 30 https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
            break
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            print_warn "GPG 密钥下载失败，重试 $RETRY_COUNT/$MAX_RETRIES..."
            sleep 2
        fi
    done
    
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        print_error "GPG 密钥下载失败"
        return 1
    fi
    
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # 添加 Docker 仓库
    print_info "添加 Docker 仓库..."
    
    # 获取发行版代码名
    OS_CODENAME=$(lsb_release -cs)
    
    # 添加 Docker 仓库（单行格式，避免换行问题）
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${OS_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 验证配置文件格式
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        print_error "Docker 源文件创建失败"
        return 1
    fi
    
    # 检查文件是否为单行（应该只有一行）
    LINE_COUNT=$(wc -l < /etc/apt/sources.list.d/docker.list)
    if [ "$LINE_COUNT" -ne 1 ]; then
        print_error "Docker 源文件格式错误（应该是单行）"
        return 1
    fi
    
    # 更新包列表
    print_info "更新包列表..."
    apt-get update
    
    # 安装 Docker
    print_info "安装 Docker..."
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    print_info "Docker 安装完成"
}

# 安装 Docker (CentOS/RHEL)
install_docker_centos() {
    print_info "开始安装 Docker (CentOS/RHEL)..."
    
    # 更新系统包
    print_info "更新系统包..."
    yum update -y
    
    # 安装必要的工具
    print_info "安装必要的工具..."
    yum install -y yum-utils
    
    # 添加 Docker 仓库
    print_info "添加 Docker 仓库..."
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # 安装 Docker
    print_info "安装 Docker..."
    yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    print_info "Docker 安装完成"
}

# 安装 Docker Compose (独立版本, 如果系统安装失败时使用)
install_docker_compose_standalone() {
    print_info "安装 Docker Compose..."
    
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    COMPOSE_DIR=/usr/local/bin
    COMPOSE_BINARY=$COMPOSE_DIR/docker-compose
    
    # 下载 Docker Compose
    print_info "下载 Docker Compose v${COMPOSE_VERSION}..."
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o $COMPOSE_BINARY
    
    # 添加执行权限
    chmod +x $COMPOSE_BINARY
    
    # 创建符号链接
    ln -sf $COMPOSE_BINARY /usr/bin/docker-compose
    
    print_info "Docker Compose 安装完成"
}

# 启动 Docker 服务
start_docker() {
    print_info "启动 Docker 服务..."
    systemctl start docker
    systemctl enable docker
    
    # 验证 Docker 是否运行
    if systemctl is-active --quiet docker; then
        print_info "Docker 服务已启动"
    else
        print_error "Docker 服务启动失败"
        exit 1
    fi
}

# 配置 Docker 加速镜像(可选)
configure_docker_mirror() {
    print_info "配置 Docker 镜像加速..."
    
    # 创建配置目录
    mkdir -p /etc/docker
    
    # 检查是否已有配置
    if [ -f /etc/docker/daemon.json ]; then
        print_warn "检测到已有 daemon.json 配置，跳过镜像加速配置"
        return
    fi
    
    # 配置国内镜像加速
    cat > /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.nju.edu.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
    
    # 重启 Docker 使配置生效
    systemctl restart docker
    
    print_info "Docker 镜像加速配置完成"
}

# 验证安装
verify_installation() {
    print_info "验证安装..."
    
    # 检查 Docker 版本
    if docker --version; then
        print_info "✓ Docker 安装成功"
    else
        print_error "✗ Docker 安装失败"
        exit 1
    fi
    
    # 检查 Docker Compose 版本
    if docker compose version 2>/dev/null || docker-compose --version 2>/dev/null; then
        print_info "✓ Docker Compose 安装成功"
    else
        print_error "✗ Docker Compose 安装失败"
        exit 1
    fi
    
    # 测试运行
    print_info "测试 Docker 运行..."
    if docker run --rm hello-world > /dev/null 2>&1; then
        print_info "✓ Docker 运行测试成功"
    else
        print_warn "⚠ Docker 运行测试失败"
    fi
}

# 显示使用信息
show_usage() {
    cat << EOF

${GREEN}安装完成！${NC}

常用命令:
  - 启动服务: systemctl start docker
  - 停止服务: systemctl stop docker
  - 重启服务: systemctl restart docker
  - 查看状态: systemctl status docker
  - 查看版本: docker --version
  - 查看 Compose 版本: docker compose version

镜像加速已配置，可以使用以下镜像源:
  - DaoCloud: https://docker.m.daocloud.io
  - DockerProxy: https://dockerproxy.com
  - 中科大: https://docker.mirrors.ustc.edu.cn
  - 南京大学: https://docker.nju.edu.cn

EOF
}

# 检查网络连接
check_network() {
    print_info "检查网络连接..."
    if curl -fsSL --max-time 5 https://download.docker.com > /dev/null 2>&1; then
        print_info "✓ 网络连接正常"
    else
        print_warn "⚠ 无法访问 Docker 官方网站，可能影响下载"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "用户取消安装"
            exit 1
        fi
    fi
}

# 主函数
main() {
    print_info "=================================================="
    print_info "  Docker + Docker Compose 一键安装脚本"
    print_info "=================================================="
    print_info "日志文件: $LOG_FILE"
    echo
    
    # 检查 root 权限
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 权限运行此脚本"
        print_info "使用命令: sudo bash install-docker.sh"
        exit 1
    fi
    
    # 创建日志目录
    mkdir -p /var/log 2>/dev/null || true
    
    # 检查网络连接
    check_network
    
    # 检测系统类型
    detect_system
    
    # 检查是否已安装
    check_docker_installed
    
    # 根据系统类型安装
    if [ "$SYSTEM_TYPE" == "ubuntu" ]; then
        install_docker_ubuntu
    else
        install_docker_centos
    fi
    
    # 启动 Docker 服务
    start_docker
    
    # 配置镜像加速
    read -p "是否配置 Docker 镜像加速？(Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        configure_docker_mirror
    fi
    
    # 验证安装
    verify_installation
    
    # 显示使用信息
    show_usage
    
    print_info "=================================================="
    print_info "  安装完成！"
    print_info "=================================================="
}

# 执行主函数
main

