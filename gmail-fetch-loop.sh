#!/bin/bash

set -u

INTERVAL="${GMAIL_FETCH_INTERVAL:-600}"
CREDENTIALS="${GMAIL_CREDENTIALS_PATH:-/app/config/gmail-service-account.json}"
USER_ID="${GMAIL_USER_ID:-}"
QUERY="${GMAIL_QUERY:-is:unread}"
ALLOW_OVERRIDE="${GMAIL_ALLOW_OVERRIDE:-}"
PROJECT="${GMAIL_PROJECT:-}"
TYPE="${GMAIL_TYPE:-}"

if [ -z "$USER_ID" ]; then
    echo "[gmail-fetch] GMAIL_USER_ID non impostato, loop disattivato."
    exit 0
fi

echo "[gmail-fetch] loop avviato"
echo "[gmail-fetch] user_id=$USER_ID"
echo "[gmail-fetch] credentials=$CREDENTIALS"
echo "[gmail-fetch] query=$QUERY"
echo "[gmail-fetch] allow_override=${ALLOW_OVERRIDE:--}"
echo "[gmail-fetch] project=${PROJECT:--}"
echo "[gmail-fetch] type=${TYPE:--}"
echo "[gmail-fetch] interval=$INTERVAL"

while true; do
    echo "[gmail-fetch] $(date -Iseconds) - controllo mailbox $USER_ID"

    RAKE_ARGS=(credentials="$CREDENTIALS" user_id="$USER_ID" query="$QUERY")
    if [ -n "$ALLOW_OVERRIDE" ]; then
        RAKE_ARGS+=(allow_override="$ALLOW_OVERRIDE")
    fi
    if [ -n "$PROJECT" ]; then
        RAKE_ARGS+=(project="$PROJECT")
    fi
    if [ -n "$TYPE" ]; then
        RAKE_ARGS+=(type="$TYPE")
    fi

    bundle exec rake redmine:email:receive_gmail "${RAKE_ARGS[@]}" \
        || echo "[gmail-fetch] errore nel fetch, riprovo tra ${INTERVAL}s"

    sleep "$INTERVAL"
done
