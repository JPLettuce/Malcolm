#!/bin/bash

# Copyright (c) 2019 Battelle Energy Alliance, LLC.  All rights reserved.

if [ -z "$BASH_VERSION" ]; then
  echo "Wrong interpreter, please run \"$0\" with bash"
  exit 1
fi

if docker-compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE_BIN=docker-compose
elif grep -q Microsoft /proc/version && docker-compose.exe version >/dev/null 2>&1; then
  DOCKER_COMPOSE_BIN=docker-compose.exe
fi

# if the docker-compose config file was specified, use it, otherwise
# let docker-compose figure it out
if [ "$1" ]; then
  CONFIG_FILE="$1"
  DOCKER_COMPOSE_COMMAND="$DOCKER_COMPOSE_BIN -f "$CONFIG_FILE""
else
  CONFIG_FILE="docker-compose.yml"
  DOCKER_COMPOSE_COMMAND="$DOCKER_COMPOSE_BIN"
fi

# force-navigate to Malcolm base directory (parent of scripts/ directory)
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH/.." >/dev/null 2>&1

# stop Malcolm if needed
$SCRIPT_PATH/stop.sh "$CONFIG_FILE"

# start Malcolm
$SCRIPT_PATH/start.sh "$CONFIG_FILE"

popd >/dev/null 2>&1
