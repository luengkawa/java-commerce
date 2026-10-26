# 第一阶段架构说明

## 架构选择

项目使用模块化单体：所有业务模块在同一个 Spring Boot 应用和进程中运行，但代码按业务领域组织。订单创建需要同时写入订单、明细、库存和流水，单体架构便于在第一阶段使用一个 MySQL 本地事务保证一致性。

## 包与依赖方向

```text
com.wakalueng.commerce
├── common       跨模块共享的响应模型、异常和基础设施
├── system       健康探测之外的最小系统接口
├── user         用户与开发环境模拟身份
├── product      商品与 SKU
├── inventory    库存与库存流水
└── order        订单、模拟支付与取消
```

依赖原则：业务模块可以依赖 `common`；Controller 调用本模块的 Service，Service 调用 Mapper；Mapper 不反向依赖 Service 或 Controller。订单编排可以调用商品和库存模块公开的服务接口，不直接操作其他模块的 Mapper。后续每个业务包再按实际需要增加 `api`、`application`、`domain` 和 `infrastructure` 子包，避免提前创建大量空目录。

## 第 2 步的调用链

```text
GET /api/v1/system/ping
        │
        ▼
SystemController
        │
        ▼
JSON: {"application":"commerce-platform","status":"UP"}
```

当前接口没有业务状态和数据库访问，因此不增加 Service 和 Mapper。业务接口落地后，学习顺序统一为请求 DTO → Controller → Service → Mapper → SQL → 响应 DTO。

## 数据层（第 4 步）

数据库使用 MySQL 8.4，表结构由 Flyway 版本化迁移管理，开发数据只在 `local` profile 额外加载。完整 ER 图和字段口径见 [database-design.md](database-design.md)。

| 模块 | 负责的表 |
| --- | --- |
| user | `app_user` |
| product | `product`、`sku` |
| inventory | `inventory`、`inventory_log` |
| order | `orders`、`order_item`、`order_status_log` |

模块只写自己负责的表。订单编排通过库存模块公开的服务预占或释放库存，不直接更新 `inventory`；跨模块读取通过对方公开接口，避免表级耦合。第一版不建物理外键，由服务层事务、唯一约束和测试保证关联完整性，所有关联列都建了索引。

测试分层：单元测试和 Spring 上下文测试使用 `test` profile，`application-test.yml` 排除 `DataSourceAutoConfiguration` 与 `FlywayAutoConfiguration`，不需要 MySQL；第 7 步为连接真实 MySQL 的集成测试增加独立 profile，不把数据库行为验证建立在内存数据库上。

## 配置策略

`application.yml` 保存所有环境都适用的安全默认值；`application-local.yml` 用于本地调试；测试通过 `application-test.yml` 降低日志噪声；部署使用 `prod` profile，并由环境变量覆盖端口和日志级别。`.env.example` 只提供变量名和安全示例，真实 `.env` 被 Git 忽略；`scripts/run-local.sh` 负责显式加载并导出变量，因为 Spring Boot 不会自动读取 `.env`。

数据源和 Flyway 配置集中在 `application.yml`，连接参数由 `DB_*` 环境变量覆盖。`local` profile 把 `classpath:db/seed` 加入 Flyway locations，`prod` 只执行 `classpath:db/migration`，避免开发数据进入部署环境。测试 profile 不初始化数据源，数据库集成测试在第 7 步使用独立 profile。

宿主机与容器的 `localhost` 各自指向自己。因此宿主机运行应用时使用 `DB_HOST=127.0.0.1`，应用容器连接 MySQL 容器时使用 Compose 服务名 `DB_HOST=mysql`。MySQL 的宿主机端口将以 `127.0.0.1:${MYSQL_HOST_PORT}:3306` 形式绑定，不对局域网或公网暴露。
