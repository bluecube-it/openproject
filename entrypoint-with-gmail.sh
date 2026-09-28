#!/bin/bash

set -e

echo "[entrypoint-with-gmail] starting"
echo "[entrypoint-with-gmail] args: $*"

if [ "${GMAIL_FETCH_ENABLED:-false}" = "true" ]; then
    echo "[entrypoint-with-gmail] starting Gmail fetch loop"
    /app/docker/prod/gmail-fetch-loop.sh &
    GMAIL_LOOP_PID=$!
    echo "[entrypoint-with-gmail] Gmail fetch loop PID: ${GMAIL_LOOP_PID}"
else
    echo "[entrypoint-with-gmail] Gmail fetch disabled"
fi

echo "[entrypoint-with-gmail] calling OpenProject entrypoint: $*"

exec /app/docker/prod/entrypoint.sh "$@"
