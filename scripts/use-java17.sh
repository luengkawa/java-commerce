#!/bin/sh
# Run with: source scripts/use-java17.sh
# JAVA17_HOME can select a custom JDK 17 installation on Linux or macOS.

if [ -n "${JAVA17_HOME:-}" ]; then
  commerce_java17_home="$JAVA17_HOME"
elif [ "$(uname -s)" = Darwin ]; then
  commerce_java17_home=$(/usr/libexec/java_home -v 17 2>/dev/null) || {
    printf '%s\n' '未找到 JDK 17，请先安装，或设置 JAVA17_HOME。' >&2
    return 1 2>/dev/null || exit 1
  }
elif [ -n "${JAVA_HOME:-}" ]; then
  commerce_java17_home="$JAVA_HOME"
else
  printf '%s\n' '请将 JAVA17_HOME 设置为 JDK 17 目录后重试。' >&2
  return 1 2>/dev/null || exit 1
fi

if [ ! -x "$commerce_java17_home/bin/java" ] || [ ! -x "$commerce_java17_home/bin/javac" ]; then
  printf '%s\n' '指定目录不包含完整 JDK，请检查 java 与 javac。' >&2
  unset commerce_java17_home
  return 1 2>/dev/null || exit 1
fi

commerce_java17_version=$("$commerce_java17_home/bin/java" -version 2>&1)
case "$commerce_java17_version" in
  *'version "17.'*) ;;
  *)
    printf '%s\n' '指定的 JDK 版本不是 17。' >&2
    unset commerce_java17_home commerce_java17_version
    return 1 2>/dev/null || exit 1
    ;;
esac

export JAVA_HOME="$commerce_java17_home"
export PATH="$JAVA_HOME/bin:$PATH"
unset commerce_java17_home commerce_java17_version
