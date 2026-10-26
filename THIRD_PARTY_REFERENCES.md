# 第三方参考与许可证记录

本项目独立实现核心业务。参考项目用于理解业务模块、数据库关系和工程组织；引入任何代码前都要再次核对具体文件和当时的许可证。

| 项目 | 参考用途 | 仓库许可证（检查日期：2026-10-26） | 代码使用情况 |
| --- | --- | --- | --- |
| [macrozheng/mall](https://github.com/macrozheng/mall) | 商城模块及订单业务范围 | Apache License 2.0 | 未复制代码 |
| [macrozheng/mall-learning](https://github.com/macrozheng/mall-learning) | Spring Boot 电商技术学习路径 | 当前仓库根目录与 GitHub License API 未发现明确许可证 | 未复制代码，仅阅读公开说明 |
| [newbee-ltd/newbee-mall](https://github.com/newbee-ltd/newbee-mall) | 前后端分离商城流程 | GPL-3.0 | 未复制代码 |
| [gz-yami/mall4j](https://github.com/gz-yami/mall4j) | 商品、订单与库存领域划分 | AGPL-3.0 | 未复制代码 |

Spring Boot、Maven Wrapper 及项目依赖由 Maven 坐标和依赖元数据管理。Maven Wrapper 发布脚本的 Apache License 2.0 文本保存在 `.mvn/wrapper/LICENSE.txt`。

第 4 步新增的数据库组件：MySQL Community Server 8.4.9（容器镜像，GPLv2）、Flyway Community 11.7.2（Apache License 2.0）、MySQL Connector/J 9.7.0（GPLv2，含 Universal FOSS Exception）和 HikariCP 6.3.3（Apache License 2.0）。镜像版本在 `compose.yaml` 固定，其余版本由 Spring Boot BOM 管理；表结构与迁移脚本为项目独立编写，未复制参考项目代码。
