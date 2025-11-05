# 多阶段构建：减少镜像大小
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app

# 复制pom.xml和源码
COPY backend/pom.xml .
COPY backend/src ./src

# 构建应用
RUN mvn clean package -DskipTests

# 运行阶段
FROM openjdk:8-jre-slim
WORKDIR /app

# 安装curl用于健康检查
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 复制构建好的jar包
COPY --from=build /app/target/backend-*.jar app.jar

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD curl -f http://localhost:8080/api/dashboard/getUserFrequency || exit 1

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]
