#!/bin/sh
# Load the explicitly selected env file and run the application from the project root.
set -eu

commerce_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
commerce_env_file=${COMMERCE_ENV_FILE:-$commerce_root/.env}

if [ ! -f "$commerce_env_file" ]; then
  printf 'Environment file not found: %s\n' "$commerce_env_file" >&2
  printf '%s\n' 'Create it with: cp .env.example .env' >&2
  exit 1
fi

# .env is treated as trusted shell syntax. Export every assignment loaded from it.
set -a
# shellcheck disable=SC1090
. "$commerce_env_file"
set +a

case "${SERVER_PORT:-8080}" in
  *[!0-9]*|'')
    printf '%s\n' 'SERVER_PORT must be a number.' >&2
    exit 1
    ;;
esac

if [ "${SERVER_PORT:-8080}" -lt 1 ] || [ "${SERVER_PORT:-8080}" -gt 65535 ]; then
  printf '%s\n' 'SERVER_PORT must be between 1 and 65535.' >&2
  exit 1
fi

if [ -n "${JAVA17_HOME:-}" ]; then
  commerce_java17_home=$JAVA17_HOME
elif [ "$(uname -s)" = Darwin ]; then
  commerce_java17_home=$(/usr/libexec/java_home -v 17 2>/dev/null) || {
    printf '%s\n' 'JDK 17 was not found. Install it or set JAVA17_HOME.' >&2
    exit 1
  }
elif [ -n "${JAVA_HOME:-}" ]; then
  commerce_java17_home=$JAVA_HOME
else
  printf '%s\n' 'Set JAVA17_HOME to a JDK 17 installation.' >&2
  exit 1
fi

commerce_java17_version=$("$commerce_java17_home/bin/java" -version 2>&1)
case "$commerce_java17_version" in
  *'version "17.'*) ;;
  *)
    printf '%s\n' 'The selected JDK is not version 17.' >&2
    exit 1
    ;;
esac

export JAVA_HOME="$commerce_java17_home"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$commerce_root"
exec ./mvnw spring-boot:run
