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

FROM python:3.10-slim
COPY --from=source /app/dist /app

WORKDIR /app

RUN set -ex \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip list \
    && apt-get update && apt install -y \
       tini \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache/*

EXPOSE 9763

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python3","main.py"]
