#
# Dockerfile for lx-music-api-server
#

FROM alpine as source

ENV REPO_URL https://github.com/lxmusics/lx-music-api-server-python.git

WORKDIR /app

RUN set -ex \
    && apk add --update --no-cache git \
    && git clone ${REPO_URL} . \
    && mkdir dist \
    && echo "$(git tag | sort -V | tail -1)+$(git rev-parse --short HEAD)" > dist/version \
    && mv main.py common modules requirements.txt -t dist

FROM esme518/wolfi-base-python:3.10

ENV PYTHONUNBUFFERED=1

COPY --from=source /app/dist /app
WORKDIR /app

RUN set -ex \
    && apk add --update --no-cache \
       tini \
    && export PYTHONDONTWRITEBYTECODE=1 \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip list \
    && rm -rf /root/.cache/*

EXPOSE 9763

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python","main.py"]
