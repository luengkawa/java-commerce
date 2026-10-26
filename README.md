# Java 电商订单与库存管理平台

这是一个用于学习 Java 后端、订单事务和库存一致性的模块化单体项目。目前已完成工具链、Spring Boot 最小工程、运行配置，以及 MySQL 表结构设计、Flyway 迁移脚本和 MySQL Compose 服务；应用连接数据库并执行迁移在第 5 步验证。

详细路线、完成状态和学习入口见 [PROJECT_GUIDE.md](PROJECT_GUIDE.md)。架构说明见 [docs/architecture.md](docs/architecture.md)，数据库的 ER 图与字段口径见 [docs/database-design.md](docs/database-design.md)。
源码仓库：[https://github.com/luengkawa/java-commerce](https://github.com/luengkawa/java-commerce)。

## 快速开始

### 1. 准备环境变量

```sh
cp .env.example .env
# 编辑 .env，替换 DB_PASSWORD 与 MYSQL_ROOT_PASSWORD 两个占位值
```

若本机 3306 端口已被其他 MySQL 占用，需要同时修改 `.env` 中的 `DB_PORT` 和 `MYSQL_HOST_PORT`，例如都改为 `3307`。

### 2. 构建与测试

```sh
source scripts/use-java17.sh
./mvnw clean verify
```

`test` profile 不连接数据库；数据库集成测试在第 7 步加入。

### 3. 启动 MySQL

```sh
docker compose up -d --wait mysql
docker compose ps
```

容器把 MySQL 映射到宿主机回环地址 `127.0.0.1:${MYSQL_HOST_PORT}`，不监听局域网。停止容器使用 `docker compose stop mysql`；`docker compose down` 会删除容器但保留数据卷，不要用 `down -v` 做日常停止。

### 4. 启动应用（第 5 步验证）

```sh
./scripts/run-local.sh
```

`run-local.sh` 显式读取 `.env`、将其中的变量导出给 Spring Boot，并使用 JDK 17 启动。Spring Boot 不会自动读取项目根目录的 `.env`。如需使用其他文件：

```sh
COMMERCE_ENV_FILE=/absolute/path/to/runtime.env ./scripts/run-local.sh
```

启动后访问：

```sh
curl http://localhost:8080/api/v1/system/ping
curl http://localhost:8080/actuator/health
```

宿主机运行应用时 `DB_HOST=127.0.0.1`；应用与 MySQL 都在 Compose 网络中时应使用 `DB_HOST=mysql`，不能使用 `localhost`。Flyway 在应用启动时执行 `db/migration` 下的结构迁移，`local` profile 还会加载 `db/seed` 下的开发数据。
