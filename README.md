# Java 电商订单与库存管理平台

这是一个用于学习 Java 后端、订单事务和库存一致性的模块化单体项目。目前已完成工具链、Spring Boot 最小工程和运行配置，业务与数据库将在后续步骤逐步实现。

详细路线、完成状态和学习入口见 [PROJECT_GUIDE.md](PROJECT_GUIDE.md)。架构说明见 [docs/architecture.md](docs/architecture.md)。

## 当前运行方式

```sh
cp .env.example .env
# 编辑 .env，替换两个密码占位值
./mvnw clean verify
./scripts/run-local.sh
```

`run-local.sh` 显式读取 `.env`、将其中的变量导出给 Spring Boot，并使用 JDK 17 启动。Spring Boot 不会自动读取项目根目录的 `.env`。如需使用其他文件：

```sh
COMMERCE_ENV_FILE=/absolute/path/to/runtime.env ./scripts/run-local.sh
```

启动后可访问：

```sh
curl http://localhost:8080/api/v1/system/ping
curl http://localhost:8080/actuator/health
```

当前最小工程不连接数据库。宿主机运行应用时 `DB_HOST=127.0.0.1`；应用与 MySQL 都在 Compose 网络中时应使用 `DB_HOST=mysql`，不能使用 `localhost`。MySQL 启动、迁移和完整容器部署会在后续步骤完成。
