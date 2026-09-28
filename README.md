# openproject

Custom [OpenProject](https://www.openproject.org/) Docker image built on top of
`openproject/openproject:17`, adding:

- **Free-enterprise-mode patch** (`enterprise_token.rb`) — enables all Enterprise
  features without a license token. This is the public *markasoftware* patch and
  contains **no secret**.
- **Gmail fetch loop** — an optional background loop that periodically imports
  emails from a Gmail mailbox into OpenProject work packages using the
  `redmine:email:receive_gmail` rake task.

The image is published to GitHub Container Registry as
`ghcr.io/bluecube-it/openproject`.

## What this image does

| File                          | Destination in image                | Purpose                                   |
| ----------------------------- | ----------------------------------- | ----------------------------------------- |
| `enterprise_token.rb`         | `/app/models/enterprise_token.rb`   | Free-enterprise-mode patch                |
| `entrypoint-with-gmail.sh`    | `/app/docker/prod/entrypoint-with-gmail.sh` | Wrapper entrypoint that starts the loop and then delegates to the stock entrypoint |
| `gmail-fetch-loop.sh`         | `/app/docker/prod/gmail-fetch-loop.sh` | Polls Gmail and runs the import rake task |

The stock `openproject/openproject` entrypoint and `supervisord` command are
preserved.

## Build

```bash
docker build -t openproject:local .

# Pin a different upstream base
docker build --build-arg OPENPROJECT_VERSION=17 -t openproject:local .
```

## Run

```bash
docker run -d --name openproject \
  -p 8080:80 \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  -e OPENPROJECT_HOST__NAME=openproject.example.com \
  -e OPENPROJECT_HTTPS=false \
  openproject:local
```

See the [OpenProject Docker documentation](https://www.openproject.org/docs/installation-and-operations/installation/docker/)
for the full environment reference.

## Gmail fetch

The loop is **disabled by default**. Enable it with:

| Variable                 | Default                                    | Description                                        |
| ------------------------ | ------------------------------------------ | -------------------------------------------------- |
| `GMAIL_FETCH_ENABLED`    | `false`                                    | Must be `true` to start the loop                   |
| `GMAIL_FETCH_INTERVAL`   | `60`                                       | Seconds between each poll                          |
| `GMAIL_CREDENTIALS_PATH` | `/app/config/gmail-service-account.json`   | Path to the Google service account JSON            |
| `GMAIL_USER_ID`          | –                                          | OpenProject user id used to receive the emails     |
| `GMAIL_QUERY`            | `is:unread`                                | Gmail search query                                 |
| `GMAIL_PROJECT`          | –                                          | Target OpenProject project identifier              |

> **No credentials are baked into the image.** Mount the service account JSON
> read-only at runtime:

```bash
docker run -d --name openproject \
  -p 8080:80 \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  -e OPENPROJECT_HOST__NAME=openproject.example.com \
  -e OPENPROJECT_HTTPS=false \
  -e GMAIL_FETCH_ENABLED=true \
  -e GMAIL_USER_ID=1 \
  -e GMAIL_PROJECT=my-project \
  -v /secure/gmail-service-account.json:/app/config/gmail-service-account.json:ro \
  openproject:local
```

`gmail-service-account.json.example` is a placeholder; copy it to
`gmail-service-account.json` for local tests. The real file is ignored by git and
excluded from the Docker build context.

## Pulling from GHCR

```bash
docker pull ghcr.io/bluecube-it/openproject:latest
docker pull ghcr.io/bluecube-it/openproject:17
```

Tags are produced by the release workflow:
`latest`, the full release tag, and semver tags (`{{major}}`, `{{major}}.{{minor}}`, `{{version}}`).

## Releases

Create a GitHub release: `.github/workflows/release.yml` builds and pushes a
multi-arch image (`linux/amd64`, `linux/arm64`) to GHCR. On any push/PR,
`.github/workflows/ci.yml` builds the image without pushing.

The upstream base version can be overridden per repository with the
`OPENPROJECT_VERSION` repository variable (default `17`).

## Security

This repository is public: **never commit credentials**. The real
`gmail-service-account.json` is listed in `.gitignore` and `.dockerignore`.

## License

OpenProject is licensed under GPL-3.0. This derived image keeps the same license;
see [LICENSE](LICENSE).
