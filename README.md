## Docker部署到服务器
前置要求：
- 服务器用户名:allaboutafrog，用户密码:Baileren2012#
- HBuilderX发行H5完成
- 根据本机部署编写相关线上部署文件Dockerfile.server,docker-compose-sever.yml,nginx.server.comf
### 1.安装Docker和Docker Compose

#### 脚本安装
- chmod +x install-docker.sh
- sudo bash install-docker.sh
#### 手动安装（可选）

##### Ubuntu/Debian 系统：

```bash
# 更新系统包
apt-get update

# 安装必要的工具
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker 仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动 Docker 服务
systemctl start docker
systemctl enable docker

# 验证安装
docker --version
docker compose version
```

### 2.XFTP上传文件
```txt
├── backend/                           # 后端项目目录
│   ├── src/                           # 源代码
│   │   └── main/
│   │       ├── java/                  # Java源码
│   │       │   └── com/au/backend/
│   │       │       ├── BackendApplication.java
│   │       │       ├── controller/    # 控制器
│   │       │       ├── service/       # 业务逻辑层
│   │       │       ├── mapper/        # 数据访问层
│   │       │       ├── model/         # 数据模型
│   │       │       │   ├──entity      #实体类
│   │       │       │   ├──dto         #请求对象
│   │       │       │   └──base        #通用响应类等
│   │       │       └── config/        # 配置类
│   │       └── resources/             # 配置文件和sql脚本等
│   │           ├── application.yml
│   │           ├── application-prod.yml #身缠
│   │           └── log4j2-spring.xml
│   ├── pom.xml                        # Maven配置文件
│   └── Dockerfile.server              # Docker构建文件
├── frontend/                          # 前端静态文件（稍后添加）
│   ├── index.html
│   ├── assets/
│   └── static/
├── nginx/
│   └── nginx.server.conf                     # Nginx配置文件
└── docker-compose-server.yml          # Docker Compose配置
```
- nginx配置文件绑定后端端口8080
-执行命令 wget https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js -O echarts.min.js
-以防万一配置openjdk8：sudo apt install openjdk-8-jdk（也可以不用，只使用Nginx采用）

### 3.Docker Compose一键部署

#### 1.创建环境变量文件
```bash
cat > .env << EOF
# MySQL配置
MYSQL_ROOT_PASSWORD=123456                      # MySQL root管理员密码
MYSQL_DATABASE=test_user                        # 创建的数据库名称
MYSQL_USER=test_user                            # 应用数据库用户名
MYSQL_PASSWORD=123456                           # 应用数据库用户密码

# Spring Boot数据库连接配置
SPRING_DATASOURCE_USERNAME=root                 # 后端连接MySQL使用的用户名
SPRING_DATASOURCE_PASSWORD=123456               # 后端连接MySQL使用的密码（与MYSQL_ROOT_PASSWORD=123456
EOF
```
- 验证 MySQL 运行：sudo docker ps | grep mysql

#### 2.确保权限正确（只有文件所有者可读写）
chmod 600 .env

#### 3. 启动所有服务（MySQL + 后端 + Nginx）
docker compose -f docker-compose-server.yml up -d

#### 4. 查看服务状态
docker compose -f docker-compose-server.yml ps
- 确保后端、Nginx正常启动和数据库连接正常
如果出现问题：
后端日志: docker compose -f docker-compose-server.yml logs backend --tail=100

### 4.验证部署

#### 1.校验前端
需要下载curl
- curl http://localhost

#### 2.测试 Nginx 健康检查
- curl http://localhost/health

#### 3.校验后端
- curl http://localhost/api/dashboard/getUserFrequency

#### 4.浏览器访问
- http://34.84.232.200
- http://34.84.232.200/api/dashboard/getUserFrequency



