# Java 电商订单与库存管理平台：按部署路线学习与执行

## 使用方式

从第 1 步按顺序推进，每完成一步再进入下一步。未完成使用 `- [ ]`，完成并验证后改为 `- [x]`。学习自测由你实际掌握后勾选。

本文同时记录开发与部署；尚未实现的步骤先保留清单，代码落地后补充真实文件链接、可复制命令和验证结果。预期结果不能当成实际执行结果。

本机已有项目目录，命令默认在项目根目录执行。换机器时先获取本项目源码，再按本路线检查环境。测试随业务开发同步进行，第 7 步集中执行完整验证。

## 路线总览

| 顺序 | 步骤 | 当前状态 | 完成条件 |
| --- | --- | --- | --- |
| 1 | [环境准备](#step-01) | 已完成，学习自测待本人完成 | JDK 17、Wrapper、Docker 检查通过 |
| 2 | [Spring Boot 工程初始化](#step-02) | 已完成，学习自测待本人完成 | 工程可构建，最小启动测试通过 |
| 3 | [源码版本与运行配置](#step-03) | 已完成，学习自测待本人完成 | 配置可复现，敏感信息不入库 |
| 4 | [MySQL 与表结构准备](#step-04) | 待完成 | 数据库就绪，表设计与迁移脚本已准备 |
| 5 | [本地应用启动与迁移](#step-05) | 待完成 | 空库迁移、连接与健康检查通过 |
| 6 | [核心业务开发与学习](#step-06) | 待完成 | 下单、支付、取消和库存流程完成 |
| 7 | [自动化测试、打包与业务联调](#step-07) | 待完成 | 测试通过，JAR 与本地冒烟验证通过 |
| 8 | [Docker Compose 全容器部署](#step-08) | 待完成 | 容器运行、业务冒烟与持久化验证通过 |
| 9 | [备份恢复、升级与回滚演练](#step-09) | 待完成 | 备份可恢复，升级回滚流程已验证 |
| 10 | [第一阶段本地验收](#step-10) | 待完成 | 完整流程可从独立环境复现 |
| 11 | [Linux 服务器演示部署](#step-11) | 待完成，可选分支 | 服务器环境独立验收通过 |
| 12 | [日常运维与排错](#step-12) | 持续完善 | 排错说明随实际操作补充 |

当前已完成第 1、2、3 步，学习自测留给本人完成。第 11 步需要服务器，第 12 步可在任何步骤遇到问题时查阅。后续技术阶段在第一阶段本地验收后再逐步推进。

## 项目边界与当前状态

- [x] 检查工作目录：初次检查只有 `.git`，没有业务代码和历史提交。
- [x] 确认架构：模块化单体，Java 17、Spring Boot 3.x、MyBatis-Plus、MySQL 8。
- [x] 确认第一阶段范围：单店单仓、多 SKU 订单、模拟支付、取消订单。
- [x] 确认库存规则：下单预占、支付核销、取消释放。
- [x] 确认身份方案：开发和测试使用模拟身份，所有订单操作校验归属。
- [x] 补齐并验证开发环境。
- [ ] 完成第一阶段核心业务。
- [ ] 完成自动化测试和本地部署验收。

首次环境检查：仅发现 JDK 22；未找到系统 Maven；Docker 已安装但 Desktop 暂停。这是历史检查结果，当前验证状态见第 1 步和文末验证日志。使用 Maven Wrapper 后无需额外安装系统 Maven。

第一阶段不实现 Redis、RabbitMQ、AI、真实支付、购物车、优惠券、物流和退款。防超卖、幂等和事务正确性从第一阶段保证。

## 每一步的学习与验证记录

完成下文任一步骤时，在对应小节补齐：

| 项目 | 记录要求 |
| --- | --- |
| 目标 | 解决什么业务或工程问题 |
| 代码入口 | 链接实际存在的代码、配置、SQL 和测试文件 |
| 阅读顺序 | 请求 → Controller → Service → Mapper → SQL |
| 操作 | 执行位置、命令、所需环境变量 |
| 原理 | 为什么采用此实现，有什么取舍 |
| 验证 | 预期结果与实际结果分开记录 |
| 学习自测 | 能否解释关键设计并通过修改测试验证理解 |
| 完成记录 | 日期、执行环境、结果或阻塞原因 |

<a id="step-01"></a>

## 第 1 步：环境准备

- [x] 检查操作系统、CPU 架构、Git、磁盘空间及端口占用。
- [x] 安装或选择 JDK 17，配置 JAVA_HOME，不删除已有 JDK 22。
- [x] 恢复 Docker Desktop，验证 Docker Engine 和 Compose 可用。
- [x] 验证 Maven Wrapper 的执行权限、首次下载与 Java 版本。
- [x] 记录实际环境版本和依赖下载问题。

在项目根目录进行基础检查：

```sh
pwd
git status --short
java -version
/usr/libexec/java_home -V  # 仅 macOS
docker version
docker compose version
docker info
```

本项目 Wrapper 已创建，可执行 `./mvnw -version`。学习重点：区分 Docker 客户端已安装与 Docker 服务可用。

### 1.1 本次环境准备的文件入口

| 文件 | 用途 | 推荐阅读内容 |
| --- | --- | --- |
| [scripts/use-java17.sh](scripts/use-java17.sh) | 在当前终端切换到 JDK 17 | 如何发现 JDK、验证版本，以及设置 JAVA_HOME 和 PATH |
| [scripts/check-env.sh](scripts/check-env.sh) | 检查 Java、Wrapper、Docker、磁盘与端口 | 命令退出码、失败计数和环境检查顺序 |
| [.mvn/wrapper/maven-wrapper.properties](.mvn/wrapper/maven-wrapper.properties) | 固定 Maven 3.9.11 与下载文件校验和 | distributionUrl 和 distributionSha256Sum |
| [mvnw](mvnw) / [mvnw.cmd](mvnw.cmd) | Apache 官方 Wrapper 3.3.4，分别用于 Unix 与 Windows | 了解下载和缓存机制，无需逐行学习官方脚本 |
| [.gitignore](.gitignore) / [.gitattributes](.gitattributes) | 排除本地配置与构建产物，统一脚本换行 | 为什么 Wrapper 需要提交，而密码和 target 不需要 |

本步骤只准备工具链，尚无 `pom.xml` 和业务代码。因此 `./mvnw -version` 可以成功，但暂时不能执行项目构建。Windows Wrapper 已加入，未在 Windows 上实测；本次只验证 macOS。

### 1.2 在当前电脑选择 Java 17

在项目根目录运行：

```sh
source scripts/use-java17.sh
echo "$JAVA_HOME"
java -version
javac -version
./mvnw -version
bash scripts/check-env.sh
```

预期 Java 与 javac 均为 17，Maven 输出 3.9.11，且其中的 Java version 为 17。环境检查全部通过时退出码为 0，关键依赖不可用时返回非 0。

`source` 在当前终端中执行脚本，才能保留导出的环境变量。直接运行 `bash scripts/use-java17.sh` 只会改变子进程环境，不能切换当前终端。新开终端后重新执行 `source`；本次没有修改全局 shell 配置，已有 JDK 22 继续保留。环境检查脚本会在其自身进程内选择 Java 17，不改变调用它的终端环境。

Linux 或需要指定其他 JDK 安装路径时：

```sh
export JAVA17_HOME='/你的JDK17目录'
source scripts/use-java17.sh
```

IDE 中还需将项目 SDK 和 Maven Runner JDK 选为 17；终端切换不会自动修改 IDE 设置。

### 1.3 在新的 Apple Silicon Mac 上安装相同 JDK

当前电脑已安装，可跳过本小节。以下为本次使用的固定版本与校验值，仅适用于 macOS ARM64，不适用于 Intel Mac 或 Linux。

```sh
commerce_jdk_work=$(mktemp -d)
curl --fail --location --show-error \
  'https://corretto.aws/downloads/resources/17.0.21.0.10/amazon-corretto-17.0.21.0.10-macosx-aarch64.tar.gz' \
  -o "$commerce_jdk_work/jdk17.tar.gz"
```

下载成功后校验，只有显示 `OK` 才继续安装：

```sh
printf '%s  %s\n' \
  '85667cd211b7cef065a35d1ffbe16a19059493ac0130be5f0f93465458525d77' \
  "$commerce_jdk_work/jdk17.tar.gz" | shasum -a 256 -c -
```

校验通过后安装到用户目录，无需管理员密码：

```sh
mkdir -p "$HOME/Library/Java/JavaVirtualMachines"
if [ -e "$HOME/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk" ]; then
  echo 'JDK 目录已存在，跳过解压，请检查现有版本。'
else
  tar -xzf "$commerce_jdk_work/jdk17.tar.gz" \
    -C "$HOME/Library/Java/JavaVirtualMachines"
fi
/usr/libexec/java_home -V
source scripts/use-java17.sh
java -version
```

本次通过 [AWS 官方下载入口](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html)获取安装包及 SHA-256；校验后安装 Corretto 17.0.21。最初尝试的 Temurin 下载速度很慢，已停止该下载并改用 Corretto。两者都是 OpenJDK 发行版，本项目仍使用 Java 17。

### 1.4 恢复 Docker 并验证

Docker Desktop 已打开但暂停时，`docker desktop start` 只会提示已经运行，不能据此认定 Engine 可用。在 Dashboard 点击 `Resume`，再执行：

```sh
docker desktop status
docker info --format 'Engine={{.ServerVersion}} OS={{.OSType}} Arch={{.Architecture}}'
docker compose version
```

Docker 未启动时可先执行 `docker desktop start --timeout 30`。Linux 不使用 Desktop 命令，应检查本机 Docker 服务。本次恢复通过 Desktop 的 Resume 按钮完成，没有为本项目创建容器或启动数据库。CLI 的能力说明见 [Docker 官方文档](https://docs.docker.com/reference/cli/docker/desktop/)。

### 1.5 Maven 首次下载与缓存

Wrapper 使用 Maven Central 官方地址下载固定的 Maven 3.9.11，校验 SHA-256，缓存在用户的 `~/.m2/wrapper/dists` 下；再次执行复用缓存。Wrapper 的行为和校验配置见 [Apache 官方文档](https://maven.apache.org/tools/wrapper/)。

第一次执行需要网络。若失败，使用以下命令查看下载细节，修复网络后重新执行；不要删除校验配置来绕过错误：

```sh
source scripts/use-java17.sh
MVNW_VERBOSE=true ./mvnw -version
```

本次准备 Maven 安装包时曾遇到 30 秒下载超时，通过延长下载时限并断点续传取得完整文件，使用官方 SHA-512 验证，并将其 SHA-256 写入 Wrapper 配置。Wrapper 脚本来自 Apache 官方发布包，保留其许可证，见 [.mvn/wrapper/LICENSE.txt](.mvn/wrapper/LICENSE.txt)。

### 1.6 学习自测

- [ ] 能解释 JDK、JVM、javac、Maven 和 Spring Boot 各自的作用。
- [ ] 能解释 JAVA_HOME 与 PATH 的区别，以及为什么修改后要检查 Maven 输出中的 Java 版本。
- [ ] 能解释系统没有 `mvn` 时，为什么 `./mvnw` 仍然可以工作。
- [ ] 能解释为什么 Docker 客户端版本正常，不代表 Engine 可以连接。
- [ ] 能独立运行环境检查脚本，并指出当前检查尚未覆盖数据库和业务功能。

自测由你实际学习后勾选，自动安装工具不会代替完成这些学习项。

### 1.7 实际验证结果（2026-10-26）

| 检查项 | 实际结果 |
| --- | --- |
| 系统 / 架构 | macOS 26.6.2 / ARM64 |
| Git | 2.49.0 |
| JDK / javac | Corretto 17.0.21，均可执行，JDK 22 保留 |
| Java 编译运行 | 在临时目录使用 `javac --release 17` 编译并运行探针，通过后自动清理临时目录 |
| 版本选择 | 在 zsh 中 source 成功；指定 JDK 22 时脚本拒绝并返回非 0 |
| Maven Wrapper | 官方 3.3.4 脚本，下载并启动 Maven 3.9.11，实际使用 Java 17.0.21 |
| Docker Engine | 29.2.1，Linux / aarch64，已从暂停恢复为 running |
| Compose | v5.1.0，版本命令成功 |
| 空间与端口 | 最后检查约 38 GiB 可用；当前用户可见范围内未发现 8080、3306 监听 |
| 检查脚本 | `bash scripts/check-env.sh` 退出码 0 |
| 脚本语法 | `bash -n scripts/check-env.sh`、`sh -n scripts/use-java17.sh`、`sh -n mvnw` 均通过 |

上述是环境验证结果，不代表 Spring Boot 已初始化或数据库连接已通过。下一步进入第 2 步工程初始化，创建 `pom.xml`、启动类、最小配置和启动测试。

<a id="step-02"></a>

## 第 2 步：Spring Boot 工程初始化

前置：第 1 步工具链检查通过。先搭建无需数据库即可启动的最小工程，数据库依赖及连接在第 4～5 步接入，避免初始化阶段因缺少数据库配置无法启动。

- [x] 准备 JDK 17 和 Maven Wrapper，验证构建使用的 Java 版本。
- [x] 初始化 Spring Boot 工程，锁定兼容的依赖版本。
- [x] 按 user、product、inventory、order 组织业务包，各包内按需分 Controller / Service / Mapper。
- [x] 配置开发、测试及部署环境，敏感信息由环境变量注入。
- [x] 建立参数校验、统一异常响应和日志基础设施。
- [x] 运行最小启动测试并补充代码阅读链接。
- [x] 提供项目目录树和依赖版本清单，说明公共基础设施与业务模块的依赖方向。
- [x] 记录参考源码的来源、用途与许可证；独立实现核心逻辑，不复制整套项目。

学习重点：Maven 生命周期、依赖注入、配置优先级、HTTP 状态码与异常处理。

### 2.1 本步目标与版本选择

建立一个不依赖数据库也能构建、测试和启动的最小 Spring Boot 应用，先验证 Java Web 工具链。采用 Spring Boot 3.5.16、Java 17 和 Maven 3.9.11；[Spring Boot 3.5.16 官方系统要求](https://docs.spring.io/spring-boot/3.5/system-requirements.html)确认至少需要 Java 17，Maven 至少需要 3.6.3。

`pom.xml` 使用 Spring Boot Parent 统一管理 Spring Framework、Jackson、Tomcat、JUnit 等传递依赖版本。项目只声明本步需要的直接依赖：

| 直接依赖 | 用途 |
| --- | --- |
| `spring-boot-starter-web` | Spring MVC、JSON 和嵌入式 Tomcat |
| `spring-boot-starter-validation` | Jakarta Bean Validation 参数校验 |
| `spring-boot-starter-actuator` | 健康检查和基础运行信息 |
| `spring-boot-starter-test` | JUnit 5、MockMvc 和测试支持，仅测试环境使用 |

Maven Enforcer 要求构建进程使用 JDK 17；编译器使用 `--release 17`。这能避免电脑默认 JDK 22 时产生无法在 Java 17 环境运行的字节码。MySQL、MyBatis-Plus 和 Flyway 在第 4 步加入。

### 2.2 代码入口与阅读顺序

| 顺序 | 文件 | 学习内容 |
| --- | --- | --- |
| 1 | [pom.xml](pom.xml) | Parent、坐标、依赖、插件和 Java 版本约束 |
| 2 | [CommerceApplication.java](src/main/java/com/wakalueng/commerce/CommerceApplication.java) | `@SpringBootApplication` 如何触发自动配置和组件扫描 |
| 3 | [application.yml](src/main/resources/application.yml) | 应用名、默认 profile、端口、优雅停机、健康接口和日志级别 |
| 4 | [application-local.yml](src/main/resources/application-local.yml) / [application-prod.yml](src/main/resources/application-prod.yml) | profile 激活与环境变量覆盖 |
| 5 | [SystemController.java](src/main/java/com/wakalueng/commerce/system/api/SystemController.java) | HTTP 请求如何进入 Controller 并序列化为 JSON |
| 6 | [ApiError.java](src/main/java/com/wakalueng/commerce/common/api/ApiError.java) | 统一错误响应及字段校验错误结构 |
| 7 | [GlobalExceptionHandler.java](src/main/java/com/wakalueng/commerce/common/exception/GlobalExceptionHandler.java) | Validation、404 和未知异常到 HTTP 响应的映射 |
| 8 | [测试目录](src/test/java/com/wakalueng/commerce) | 上下文、接口、404 和参数校验的自动化验证 |
| 9 | [architecture.md](docs/architecture.md) | 模块边界、依赖方向和后续代码阅读路径 |
| 10 | [THIRD_PARTY_REFERENCES.md](THIRD_PARTY_REFERENCES.md) | 参考用途、许可证核对和未复制代码记录 |

当前请求链：`GET /api/v1/system/ping` → `SystemController.ping()` → Jackson JSON 响应。这个接口没有业务状态，因此没有增加空 Service 或 Mapper；订单等业务接口从第 6 步开始按 DTO → Controller → Service → Mapper → SQL 阅读。

当前目录骨架：

```text
src/
├── main/
│   ├── java/com/wakalueng/commerce/
│   │   ├── CommerceApplication.java
│   │   ├── common/       # 共享响应与异常处理
│   │   ├── system/       # 系统探针
│   │   ├── user/         # 用户与模拟身份
│   │   ├── product/      # 商品与 SKU
│   │   ├── inventory/    # 库存与流水
│   │   └── order/        # 订单、支付与取消
│   └── resources/        # 公共、local、prod 配置
└── test/                 # test profile、上下文与 MVC 测试
```

### 2.3 构建、测试与运行

在项目根目录执行：

```sh
source scripts/use-java17.sh
./mvnw clean verify
./mvnw spring-boot:run
```

`clean` 清理旧构建结果，`verify` 依次校验 Java 版本、编译、运行测试并打包。启动后另开终端验证：

```sh
curl http://localhost:8080/api/v1/system/ping
curl http://localhost:8080/actuator/health
curl -i http://localhost:8080/api/v1/does-not-exist
```

预期依次得到应用状态、`{"status":"UP"}` 和结构统一的 404。按 `Ctrl+C` 停止时，日志应出现 graceful shutdown 完成信息。当前未连接数据库，启动不需要 Docker 容器。

### 2.4 自动化测试说明

| 测试 | 验证内容 |
| --- | --- |
| `CommerceApplicationTests` | test profile 下 Spring 容器能够创建 |
| `SystemControllerTest` | `/ping` 返回正确 JSON；未知路径返回统一 404 |
| `GlobalExceptionHandlerTest` | `@Valid` 失败返回 400、稳定错误码及字段错误 |

第一次执行参数校验测试时，测试 Controller 没有被 MVC 测试切片注册，请求落到静态资源处理器，暴露出未知路径被通用处理器误报成 500 的问题。最终将校验测试改为显式 standalone MVC 装配，并为 `NoResourceFoundException` 增加 404 映射。修复后重新执行完整构建通过。

### 2.5 实际验证结果（2026-10-26）

| 检查项 | 实际结果 |
| --- | --- |
| 完整构建 | `./mvnw clean verify` 成功 |
| 编译 | 10 个主代码源文件、3 个测试源文件，Java release 17 |
| 自动化测试 | 4 个测试，失败 0、错误 0、跳过 0 |
| 构建产物 | `target/commerce-platform-0.0.1-SNAPSHOT.jar` 可执行 |
| 真实启动 | 使用 Java 17 在 18080 临时端口启动，Spring Boot 3.5.16 启动成功 |
| HTTP 验证 | `/api/v1/system/ping`、`/actuator/health` 返回 200；不存在路径返回统一 404 |
| 停止验证 | 发送中断信号后日志确认 graceful shutdown 完成 |
| 错误 JDK | 显式使用 JDK 22 执行 `./mvnw validate` 被 Enforcer 拒绝，并显示切换 Java 17 的提示 |

### 2.6 学习自测

- [ ] 能解释 `@SpringBootApplication` 包含的三项核心能力，以及启动类为什么放在根包。
- [ ] 能说明 Maven 的 `compile`、`test`、`package`、`verify` 生命周期顺序。
- [ ] 能从 `/api/v1/system/ping` 跟踪到 Controller，并解释对象如何变成 JSON。
- [ ] 能解释 `@Valid`、`@RestControllerAdvice` 和 `@ExceptionHandler` 如何协作。
- [ ] 能说明 `application.yml`、profile 文件和环境变量之间的配置覆盖关系。
- [ ] 能解释为什么业务模块按领域分包，以及订单模块不应直接调用库存 Mapper。

自测由你阅读和实际操作后勾选。第 2 步的工程交付已经完成，自测未勾选不影响进入第 3 步。

<a id="step-03"></a>

## 第 3 步：源码版本与运行配置

- [x] 补充真实仓库地址、克隆命令及固定版本检出步骤。
- [x] 提供 `.env.example` 并解释每个变量的用途、默认值和必填性。
- [x] 将实际 `.env` 和敏感文件加入 Git 忽略规则。
- [x] 明确本地运行与容器运行的数据库地址区别。
- [x] 确定应用端口，默认 8080；本地 MySQL 端口仅绑定回环地址。
- [x] 写明环境变量如何传给应用，不能假设 Spring Boot 自动读取 `.env`。

学习重点：宿主机的 localhost 与容器的 localhost 不同，容器之间通过服务名连接。

### 3.1 源码版本状态

当前真实源码位置是本机目录 `/Users/wakalueng/Documents/ChatGPT/java电商`，真实远端仓库是 [https://github.com/luengkawa/java-commerce](https://github.com/luengkawa/java-commerce)。本地第 3 步提交用 `step-03` 标签固定，可以用 detached HEAD 复现该交付状态。

在新目录中克隆主分支并检出固定版本：

```sh
git clone https://github.com/luengkawa/java-commerce.git commerce-platform
cd commerce-platform
git fetch --tags --prune
git checkout --detach step-03
git status --short --branch
```

`--detach` 用于复现标签指向的固定提交，不会随后续分支更新而变化。日常开发应检出分支，不在 detached HEAD 上直接开发。

### 3.2 环境变量清单

可提交的模板是 [`.env.example`](.env.example)。将它复制为 `.env` 后，必须替换两个密码占位值；`.env` 及私钥、证书、keystore 和 `secrets/` 目录均由 [`.gitignore`](.gitignore) 排除。

| 变量 | 模板值 / 默认值 | 用途 | 必填性 |
| --- | --- | --- | --- |
| `SPRING_PROFILES_ACTIVE` | `local` | 激活本地配置；部署环境使用 `prod` | 否，Spring 安全默认为 `local` |
| `SERVER_PORT` | `8080` | Spring Boot HTTP 监听端口 | 否 |
| `APP_LOG_LEVEL` | `DEBUG` | 项目包 `com.wakalueng.commerce` 的日志级别 | 否，local 默认 `DEBUG`，其他 profile 默认 `INFO` |
| `ROOT_LOG_LEVEL` | `INFO` | prod profile 的根日志级别 | 否 |
| `DB_HOST` | `127.0.0.1` | MySQL 地址；Compose 内应改为 `mysql` | 第 5 步连库时必填 |
| `DB_PORT` | `3306` | MySQL 端口；Compose 内始终使用容器端口 3306 | 第 5 步连库时必填 |
| `DB_NAME` | `commerce` | 应用数据库名 | 第 4～5 步必填 |
| `DB_USERNAME` | `commerce_app` | 应用专用账号，不使用 root | 第 4～5 步必填 |
| `DB_PASSWORD` | 无安全默认，模板为占位值 | 应用数据库密码 | 第 4～5 步必填，必须替换 |
| `MYSQL_HOST_PORT` | `3306` | MySQL 映射到宿主机的端口 | 第 4 步启动容器时必填 |
| `MYSQL_ROOT_PASSWORD` | 无安全默认，模板为占位值 | MySQL 容器初始化 root 密码，应用不使用它 | 第 4 步启动容器时必填，必须替换 |

当前尚未引入 JDBC 依赖，所以 `DB_*` 变量在第 4～5 步之前不会被应用使用，它们在本步先固定命名和运行边界。

### 3.3 宿主机与容器地址

| 运行位置 | `DB_HOST` | `DB_PORT` | 原因 |
| --- | --- | --- | --- |
| 应用在宿主机，MySQL 在容器 | `127.0.0.1` | `${MYSQL_HOST_PORT}`，默认 3306 | 应用访问宿主机映射端口 |
| 应用和 MySQL 都在 Compose | `mysql` | `3306` | Compose DNS 使用服务名，容器内 `localhost` 只是当前容器 |

应用默认使用 8080。第 4 步的 MySQL Compose 端口必须写成 `127.0.0.1:${MYSQL_HOST_PORT}:3306`，不得写成 `${MYSQL_HOST_PORT}:3306`；前者只监听宿主机回环地址，后者默认可能监听所有网卡。

### 3.4 显式加载 `.env`

Spring Boot 不会自动读取项目根目录的 `.env`。本项目通过 [`scripts/run-local.sh`](scripts/run-local.sh) 把文件当作受信任的 POSIX shell 配置加载，将赋值全部 `export` 给 Maven/Spring Boot，并检查 JDK 17 和 HTTP 端口。

```sh
cp .env.example .env
# 编辑 .env，替换 DB_PASSWORD 和 MYSQL_ROOT_PASSWORD
./scripts/run-local.sh
```

也可在当前 shell 显式导出后手动启动：

```sh
set -a
. ./.env
set +a
source scripts/use-java17.sh
./mvnw spring-boot:run
```

`.env` 会作为 shell 代码执行，只能使用自己创建或已审查的文件，不加载不可信内容。临时指定其他配置文件时使用 `COMMERCE_ENV_FILE=/absolute/path/to/runtime.env ./scripts/run-local.sh`。

### 3.5 学习自测

- [ ] 能解释为什么 Spring Boot 不会自动读取 `.env`，以及 `export` 后子进程如何继承变量。
- [ ] 能说明宿主机、应用容器和 MySQL 容器中 `localhost` 各自指向哪里。
- [ ] 能说明为什么 `127.0.0.1:3306:3306` 比 `3306:3306` 更适合本地数据库。
- [ ] 能区分可提交的 `.env.example` 与不可提交的 `.env`。

自测由你阅读和实际操作后勾选，配置文件交付不代表已经掌握这些原理。

### 3.6 实际验证结果（2026-10-26）

| 检查项 | 实际结果 |
| --- | --- |
| 脚本语法 | `sh -n scripts/run-local.sh`、`sh -n scripts/use-java17.sh` 和 `bash -n scripts/check-env.sh` 均通过 |
| Git 忽略 | `.env`、`.env.*`、`secrets/`、私钥、证书和 keystore 命中忽略规则；`.env.example` 明确例外且可提交 |
| 完整构建 | 使用 JDK 17.0.21 执行 `./mvnw clean verify` 成功 |
| 自动化测试 | 4 个测试，失败 0、错误 0、跳过 0 |
| `.env` 加载 | 以 `COMMERCE_ENV_FILE=.env.example` 通过 `scripts/run-local.sh` 真实启动，local profile 激活，Tomcat 监听 8080 |
| HTTP 冒烟 | `/api/v1/system/ping` 和 `/actuator/health` 均返回 200 与预期 JSON |
| 停止 | 中断运行脚本后 Spring Boot 进入 graceful shutdown |
| 源码版本 | GitHub 公开仓库 `luengkawa/java-commerce` 的 `main` 分支已推送；在独立临时目录通过 HTTPS 克隆成功，远程 URL、分支和提交一致，克隆副本再次执行 4 个测试全部通过；`step-03` 标签固定最终交付提交 |

<a id="step-04"></a>

## 第 4 步：MySQL 与表结构准备

前置：第 3 步已准备数据库环境变量。本步准备表结构和 MySQL 服务，第 5 步启动应用并执行迁移。

- [ ] 编写 ER 图，明确用户、商品、SKU、库存、订单、订单明细、库存流水和订单状态日志关系。
- [ ] 明确主键、外键策略、唯一约束、索引、金额精度及时间口径。
- [ ] 引入 Flyway 并编写首版迁移脚本；实际执行与空库验证在第 5 步完成。
- [ ] 单独提供开发测试数据，重复执行不会制造重复记录。

学习重点：商品与 SKU 的区别、订单快照、索引与事务，不使用浮点数表示金额。

### 4.1 启动 MySQL

- [ ] 提供数据库建库和用户授权步骤，应用不使用 root；说明 Flyway 迁移所需权限。
- [ ] 提供只启动 MySQL 的 Compose 命令。
- [ ] 等待 MySQL 健康检查通过，验证连接与账号权限。

<a id="step-05"></a>

## 第 5 步：本地应用启动与迁移

前置：MySQL 已健康就绪，迁移脚本已准备。先运行通用健康检查，业务接口验收在第 7 步进行。

- [ ] 提供 Maven Wrapper 启动应用的完整命令与环境变量配置。
- [ ] 验证 Flyway 自动迁移完成。
- [ ] 显式加载开发数据并验证可重复执行。
- [ ] 检查应用健康接口与启动日志。
- [ ] 补充 IDE 本地启动配置，验证 IDE 与终端使用相同的 Java 版本和应用配置。
- [ ] 验证停止、重启后数据保留。

学习重点：启动日志、连接池、迁移记录以及 Spring 事务代理。

### 5.1 数据库初始化与迁移验证

- [ ] 提供登录数据库、查看表结构、索引和 Flyway 历史的命令。
- [ ] 验证空库初始化与已有数据库增量升级两种场景。
- [ ] 明确字符集、时区和金额精度。
- [ ] 提供订单、库存、流水一致性核对 SQL。
- [ ] 说明已执行的迁移不能随意修改，应使用新版本迁移。
- [ ] 补充迁移失败的定位步骤，不默认删库重建。
- [ ] 验证数据库非负库存约束及请求幂等唯一约束。

<a id="step-06"></a>

## 第 6 步：核心业务开发与学习

前置：第 5 步应用已能连接数据库并启动。按以下顺序实现，每个模块同步编写测试、补充接口示例和代码阅读入口。

### 6.1 基础接口

- [ ] 实现测试用户、商品和 SKU 的必要管理及查询接口。
- [ ] 实现开发与测试专用模拟身份解析，禁止在正式配置中启用。
- [ ] 区分请求 DTO、响应 DTO 和持久化实体。
- [ ] 完成分页、参数校验、资源不存在等异常处理。
- [ ] 补充接口文档、调用示例和对应测试。
- [ ] 在编码前确定接口路径、方法、请求和响应示例、错误码及分页规则，并随实现保持同步。
- [ ] 明确商品上下架规则：不可售商品不能创建新订单，历史订单仍可查询。

学习重点：跟踪一次完整 HTTP 请求，解释各层职责。

### 6.2 库存与创建订单

- [ ] 区分可用库存和预占库存，使用数据库条件更新防止超卖。
- [ ] 多 SKU 按固定顺序操作，任一库存不足时整单回滚。
- [ ] 订单、明细、库存及流水在同一事务提交。
- [ ] 服务端计算价格，保存商品名、SKU 属性、成交单价与收货信息快照。
- [ ] 创建订单使用用户范围内唯一请求键；同键同内容返回原结果，不同内容拒绝。
- [ ] 验证库存不足、并发下单、重复请求和异常回滚。
- [ ] 明确请求边界：空明细、非正数量、重复 SKU、数量上限及金额溢出的校验与测试。
- [ ] 提供初始库存及补货入口，记录调整原因和流水；不能通过覆盖库存破坏已有预占。
- [ ] 验证响应丢失后使用相同请求键重试能够取回已提交订单。
- [ ] 补充创建订单断点调试路径，跟踪请求进入、事务执行、SQL 操作与提交或回滚。

学习重点：条件 UPDATE、行锁、事务传播、死锁风险、唯一约束和幂等。

### 6.3 模拟支付与订单取消

- [ ] 实现状态：待支付 → 已支付，或待支付 → 已取消。
- [ ] 支付核销预占库存，取消释放库存，同时写入流水与状态日志。
- [ ] 支付和取消竞争时只允许一个转换成功。
- [ ] 重复支付、取消不重复变更库存；已支付订单不能直接取消。
- [ ] 查询、支付、取消均验证订单归属。
- [ ] 完成状态转换、竞争条件及越权测试。
- [ ] 说明第一阶段未支付订单仅手动取消，可能持续占用库存；超时自动取消留到第二阶段实现，不能宣称已支持。

学习重点：状态机、条件更新、事务内一致性和业务幂等。

<a id="step-07"></a>

## 第 7 步：自动化测试、打包与业务联调

前置：核心业务已实现并已随开发完成对应测试。本步统一执行验证、打包与本地业务联调。

### 7.1 自动化测试与打包

- [ ] 分别提供单元测试、MySQL 集成测试、完整检查和打包命令。
- [ ] 集成测试使用独立数据库或临时容器，不操作开发数据。
- [ ] 记录 Docker 不可用时无法执行的测试，不记为通过。
- [ ] 标明测试报告路径与失败定位方法。
- [ ] 验证构建出的 JAR 能启动并完成冒烟流程。
- [ ] 配置测试失败导致构建失败；完整验证时不能将集成测试静默跳过并报告全部通过。

学习重点：单元测试与集成测试的边界，以及为什么不能只用内存数据库验证 MySQL 锁行为。

### 7.2 本地业务冒烟验证

- [ ] 提供按顺序执行的 HTTP 示例或脚本，自动传递实际返回的 ID。
- [ ] 查询商品与初始库存。
- [ ] 创建多 SKU 订单，核对可用库存减少、预占库存增加。
- [ ] 模拟支付，核对订单状态与预占核销。
- [ ] 创建另一订单并取消，核对库存释放。
- [ ] 重复请求，核对没有重复订单和重复库存变更。
- [ ] 库存不足时验证整单回滚。
- [ ] 使用不同用户验证归属限制。
- [ ] 通过自动化并发测试验证支付取消竞争与防超卖，不能用顺序请求代替。

<a id="step-08"></a>

## 第 8 步：Docker Compose 全容器部署

前置：第 7 步测试通过，JAR 已验证可运行。本步验证完整应用与数据库的容器化运行。

- [ ] 编写多阶段 Dockerfile，固定镜像版本，以非 root 用户运行应用。
- [ ] 提供应用与 MySQL 的 Compose 配置。
- [ ] 配置数据库数据卷、健康检查、启动依赖和重启策略。
- [ ] 补充构建、后台启动、查看状态、查看日志、重启和停止命令。
- [ ] 验证应用通过服务名连接 MySQL。
- [ ] 验证容器重建后订单、库存仍然存在。
- [ ] 将删除数据卷作为独立破坏性操作说明，不混入普通停止流程。
- [ ] 验证 Compose 配置解析，健康检查命令所需工具实际存在于镜像内。
- [ ] 配置并记录 JVM 内存、容器资源和连接池参数，验证数据库短暂不可用后的恢复。
- [ ] 配置应用优雅停机及容器停止等待时间，验证关闭过程不会留下部分提交的订单。
- [ ] 对容器环境重新执行第 7.2 节业务冒烟脚本，记录容器部署的独立验证结果。

<a id="step-09"></a>

## 第 9 步：备份恢复、升级与回滚演练

前置：第 8 步容器部署成功。本步先在本地学习和验证；服务器部署后需对服务器数据另行配置并验证。

- [ ] 提供 MySQL 一致性备份命令，避免在命令行直接暴露密码。
- [ ] 验证备份文件，并恢复到独立数据库核对数据。
- [ ] 升级前记录代码和镜像版本，备份数据库，检查迁移兼容性。
- [ ] 使用维护窗口停止写入、执行升级并重新验收，不承诺零停机。
- [ ] 保留上一版本镜像，明确应用回滚条件。
- [ ] 旧应用不兼容新结构时使用数据库恢复流程，说明恢复点之后的数据影响。
- [ ] 分别说明停止服务、保留数据卸载与彻底清理。
- [ ] 明确备份保存位置、保留期限、访问权限和恢复点，备份不只存放于数据库所在数据卷。

<a id="step-10"></a>

## 第 10 步：第一阶段本地验收

验收范围：本地开发和全容器运行。服务器部署单独在第 11 步验收，没有服务器不影响本步骤的完成判断。

- [ ] 从全新数据库按文档成功启动。
- [ ] 多 SKU 订单创建成功，部分库存不足时全部回滚。
- [ ] 并发下单不超卖，库存与流水一致。
- [ ] 创建订单、支付、取消符合幂等规则。
- [ ] 支付和取消竞争仅一方成功。
- [ ] 用户不能查看或操作他人的订单。
- [ ] 修改商品不会改变历史订单快照。
- [ ] 容器重建后数据保留。
- [ ] 完成备份恢复验证。
- [ ] README 提供快速启动入口并链接本手册。
- [ ] 记录真实测试结果、未验证事项和关键技术总结。
- [ ] 按本手册在全新目录及独立数据卷复现一次，确认没有依赖未记录的本机配置。
- [ ] 所有已完成学习步骤包含实际代码入口、验证命令及自测题；未执行的服务器项继续保持未勾选。

<a id="step-11"></a>

## 第 11 步：Linux 服务器演示部署（可选）

前置：本地第 10 步已验收，并具备可访问的 Linux 服务器。本步为可选部署分支，未实际执行就保持未勾选。

默认以 Ubuntu 24.04 LTS 单服务器作为后续操作说明基线，实际环境另行记录。第一阶段没有正式认证，使用隔离演示配置，通过 SSH 隧道访问，不直接开放业务接口到公网。

- [ ] 记录服务器架构、内存、磁盘、操作系统和部署版本。
- [ ] 准备 SSH 登录、部署用户及部署目录。
- [ ] 安装并验证 Docker Engine 与 Compose。
- [ ] 配置防火墙，MySQL 不暴露公网。
- [ ] 演示应用端口绑定服务器回环地址，并从外部验证业务和数据库端口不可直连，不能仅凭防火墙配置推断隔离成功。
- [ ] 获取固定版本代码并设置服务器环境变量。
- [ ] 构建或加载与服务器 CPU 架构匹配的镜像。
- [ ] 启动服务并验证迁移、健康检查与日志。
- [ ] 提供 SSH 隧道命令，通过隧道执行冒烟测试。
- [ ] 配置日志轮转并验证主机重启后的服务恢复。
- [ ] 记录实际服务器验证结果；没有服务器时明确标记未验证。
- [ ] 在服务器上重新执行第 7.2 节冒烟验证，并按第 9 步配置服务器备份和恢复流程。

<a id="step-12"></a>

## 第 12 步：日常运维与排错

遇到问题时随时查阅本节；本节位于主流程之后，不要求发生过所有故障才开始下一阶段。

- [ ] 补充 JDK 版本错误、Wrapper 无执行权限和依赖下载失败的处理方法。
- [ ] 补充 Docker 暂停、镜像拉取失败与架构不匹配的处理方法。
- [ ] 补充端口冲突、容器重启、MySQL 未就绪与账号权限问题的定位方法。
- [ ] 补充数据库地址错误、Flyway 校验失败与健康检查失败的定位方法。
- [ ] 补充业务参数错误、状态冲突、死锁和事务失败的排查方法。
- [ ] 补充数据卷误用、磁盘不足、日志增长的检查方法。
- [ ] 说明如何通过请求标识关联接口错误与日志。

排错条目统一写为：现象 → 检查命令 → 原因 → 处理 → 复验。

## 后续技术阶段

- [ ] 第二阶段：商品缓存、失效策略、接口限流。
- [ ] 第二阶段：RabbitMQ 超时取消、库存释放与异步通知，验证确认、重试、重复消费和幂等。
- [ ] 第三阶段：索引、批量任务与性能优化；记录硬件、数据量、并发数、吞吐量、延迟和错误率。
- [ ] 第四阶段：Spring Security + JWT、持续集成与工程化完善。
- [ ] 第四阶段：正式授权完成后补充域名、HTTPS、反向代理和公网部署验收。
- [ ] 第五阶段前：实现最小退款流程，明确 GMV、支付订单数、客单价、退款率的统计口径。
- [ ] 第五阶段：经营统计接口和 Spring AI Tool Calling，限制工具权限并验证业务数据来源。

### 后续阶段的部署与验收补充

- [ ] 第二阶段：补齐 Redis 和 RabbitMQ 的固定版本、账号、网络、持久化、健康检查及启动命令，管理端口不直接开放公网。
- [ ] 第二阶段：处理数据库提交与消息发送之间的失败窗口，验证消息丢失补偿、重试耗尽、死信处理和超时取消与支付竞争。
- [ ] 第三阶段：提供可重复的数据生成与压测脚本，记录预热、测试时长、P50/P95/P99、错误率及库存一致性；保存优化前后同条件的原始报告。
- [ ] 第四阶段：验证注册登录、密码哈希、JWT 过期和角色权限；关闭模拟身份，配置密钥后再进入公网部署。
- [ ] 第四阶段：补齐反向代理配置、DNS、HTTPS 证书续期、转发头及真实公网验收；限制管理和健康详情接口的访问。
- [ ] 第四阶段：配置持续集成的构建、单元及集成测试，失败时阻止交付；发布版本能追溯到 Git 提交。
- [ ] 第五阶段：配置模型服务、密钥、超时和调用预算；模型不可用不影响订单核心业务，分析工具只读且校验数据访问范围。
- [ ] 各阶段均补齐启动、停止、故障恢复、测试结果与学习总结，再勾选该阶段完成项。

## 实际验证日志

| 日期 | 步骤 | 实际操作与结果 | 未完成项或阻塞 |
| --- | --- | --- | --- |
| 2026-10-26 | 初始检查 | 工作目录无业务代码；已确认第一阶段业务边界 | JDK 17、Wrapper、业务代码、测试和部署待完成 |
| 2026-10-26 | 第 1 步：环境准备 | 安装 Corretto 17.0.21；Maven Wrapper 下载并运行 3.9.11；Docker 恢复；Java 编译运行及环境检查通过 | Spring Boot、MySQL、业务开发与部署尚未执行；学习自测留给本人完成 |
| 2026-10-26 | 手册路线调整 | 将学习与部署重排为 12 个顺序步骤，保留已完成标记和历史验证结果 | 本次仅调整文档，工程初始化尚未开始 |
| 2026-10-26 | 第 2 步：Spring Boot 工程初始化 | Spring Boot 3.5.16 最小工程、模块包、profile、统一异常、测试和文档完成；4 个测试及 clean verify 通过；真实 JAR 启动、HTTP 与优雅关闭验证通过 | 数据库、MyBatis-Plus、Flyway 和业务模块实现按后续步骤完成；学习自测留给本人完成 |
| 2026-10-26 | 第 3 步：源码版本与运行配置 | 完成 `.env.example`、敏感文件忽略、显式加载脚本、端口与宿主机/容器连接说明；GitHub 公开仓库 `luengkawa/java-commerce` 的 `main` 和 `step-03` 已推送；独立克隆、固定版本检出、构建及 4 个测试通过 | 学习自测留给本人完成；MySQL、Flyway 和业务模块按后续步骤完成 |

后续每完成一步追加记录。没有执行的测试、压测和部署不得填写成功结果。
