#
# Dockerfile for lx-music-api-server
#

FROM esme518/wolfi-base-python:3.10 AS builder

ENV REPO_URL https://github.com/MeoProject/lx-music-api-server.git

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

WORKDIR /app

RUN set -ex \
    && apk add --update --no-cache git \
    && git clone --depth 1 -q ${REPO_URL} . \
    && echo "$(git tag | sort -V | tail -1)+$(git rev-parse --short HEAD)" > VERSION \
    && rm -rf .git*

RUN set -ex \
    && pip install poetry \
    && poetry install --no-root --no-interaction

FROM esme518/wolfi-base-python:3.10

COPY --from=builder /app /app
ENV LANG=C.UTF-8
ENV PYTHONUNBUFFERED=1

RUN set -ex \
    && apk add --update --no-cache \
       tini \
    && rm -rf /tmp/* /var/cache/apk/*

ENV PATH="/app/.venv/bin":$PATH

WORKDIR /app

EXPOSE 9000

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python", "main.py"]
