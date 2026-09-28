#!/bin/bash

set -u

INTERVAL="${GMAIL_FETCH_INTERVAL:-60}"
CREDENTIALS="${GMAIL_CREDENTIALS_PATH:-/app/config/gmail-service-account.json}"
USER_ID="${GMAIL_USER_ID:-}"
QUERY="${GMAIL_QUERY:-is:unread}"
PROJECT="${GMAIL_PROJECT:-}"

if [ -z "$USER_ID" ]; then
    echo "[gmail-fetch] GMAIL_USER_ID non impostato, loop disattivato."
    exit 0
fi

if [ -z "$PROJECT" ]; then
    echo "[gmail-fetch] GMAIL_PROJECT non impostato, loop disattivato."
    exit 0
fi

echo "[gmail-fetch] loop avviato"
echo "[gmail-fetch] user_id=$USER_ID"
echo "[gmail-fetch] credentials=$CREDENTIALS"
echo "[gmail-fetch] query=$QUERY"
echo "[gmail-fetch] interval=$INTERVAL"
echo "[gmail-fetch] project=$PROJECT"


while true; do
    echo "[gmail-fetch] $(date -Iseconds) - controllo mailbox $USER_ID"

    bundle exec rake redmine:email:receive_gmail \
        credentials="$CREDENTIALS" \
        user_id="$USER_ID" \
        query="$QUERY" \
        project="$PROJECT" \
        || echo "[gmail-fetch] errore nel fetch, riprovo tra ${INTERVAL}s"

    sleep "$INTERVAL"
done

