ARG OPENPROJECT_VERSION=17
FROM openproject/openproject:${OPENPROJECT_VERSION}

LABEL org.opencontainers.image.title="openproject" \
      org.opencontainers.image.description="OpenProject image with the free-enterprise-mode patch and a Gmail fetch loop" \
      org.opencontainers.image.source="https://github.com/bluecube-it/openproject" \
      org.opencontainers.image.licenses="GPL-3.0-or-later"

# Free-enterprise-mode patch (public markasoftware patch, no secret baked in).
COPY ./enterprise_token.rb app/models/enterprise_token.rb

# Optional Gmail fetch loop. No credentials are included: the service account
# JSON must be mounted at runtime (GMAIL_CREDENTIALS_PATH).
COPY gmail-fetch-loop.sh /app/docker/prod/gmail-fetch-loop.sh
COPY entrypoint-with-gmail.sh /app/docker/prod/entrypoint-with-gmail.sh

RUN chmod +x \
    /app/docker/prod/gmail-fetch-loop.sh \
    /app/docker/prod/entrypoint-with-gmail.sh

ENTRYPOINT ["/app/docker/prod/entrypoint-with-gmail.sh"]
CMD ["./docker/prod/supervisord"]
