#
# Dockerfile for lx-music-api-server
#

FROM alpine as source

ENV REPO_URL https://github.com/lxmusics/lx-music-api-server-python.git

WORKDIR /app

RUN set -ex \
    && apk add --update --no-cache git \
    && git clone ${REPO_URL} . \
    && git checkout $(git tag | sort -V | tail -1) \
    && mkdir dist \
    && echo "$(git tag | sort -V | tail -1)" > dist/version \
    && mv main.py common modules requirements.txt -t dist

FROM cgr.dev/chainguard/wolfi-base

ARG version=3.10

RUN set -ex \
    && apk add --update --no-cache \
       python-${version} \
       py${version}-pip \
       tini

COPY --from=source /app/dist /app

WORKDIR /app

RUN set -ex \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip list \
    && rm -rf /root/.cache/*

EXPOSE 9763

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python","main.py"]
