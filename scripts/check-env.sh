#!/bin/bash
# Read-only checks; no installation, daemon restart or container creation.
set -uo pipefail

commerce_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
commerce_failures=0

pass() { printf '[通过] %s\n' "$1"; }
fail() { printf '[失败] %s\n' "$1" >&2; commerce_failures=$((commerce_failures + 1)); }

printf '项目目录：%s\n' "$commerce_root"
printf '系统架构：%s / %s\n' "$(uname -s)" "$(uname -m)"

if command -v git >/dev/null 2>&1; then
  pass "$(git --version)"
else
  fail '未找到 Git'
fi

if source "$commerce_root/scripts/use-java17.sh"; then
  pass "JAVA_HOME=$JAVA_HOME"
  java -version
  javac -version
else
  fail 'JDK 17 不可用'
fi

if [ -x "$commerce_root/mvnw" ]; then
  if "$commerce_root/mvnw" -version; then
    pass 'Maven Wrapper 可用（此项不代表业务工程已构建）'
  else
    fail 'Maven Wrapper 执行失败，请检查 JDK、网络及下载配置'
  fi
else
  fail 'mvnw 不存在或没有执行权限'
fi

if command -v docker >/dev/null 2>&1; then
  if commerce_docker_info=$(docker info --format 'Engine={{.ServerVersion}} OS={{.OSType}} Arch={{.Architecture}}' 2>&1); then
    pass "$commerce_docker_info"
  else
    fail "Docker Engine 不可用：$commerce_docker_info"
  fi
  if docker compose version; then
    pass 'Docker Compose 可用'
  else
    fail 'Docker Compose 不可用'
  fi
else
  fail '未找到 Docker'
fi

printf '\n磁盘空间（人工确认足够存放镜像、数据及备份）：\n'
df -h "$commerce_root"
if command -v lsof >/dev/null 2>&1; then
  for commerce_port in 8080 3306; do
    if lsof -nP -iTCP:"$commerce_port" -sTCP:LISTEN; then
      printf '[提示] 端口 %s 已被占用，启动项目时需要改端口或处理占用。\n' "$commerce_port"
    else
      printf '[提示] 当前未发现端口 %s 的监听进程（仅反映当前用户可见进程）。\n' "$commerce_port"
    fi
  done
fi

if [ "$commerce_failures" -ne 0 ]; then
  printf '\n环境检查失败，共 %s 项。\n' "$commerce_failures" >&2
  exit 1
fi
printf '\n环境检查通过。尚未检查业务代码、数据库连接或容器部署。\n'
