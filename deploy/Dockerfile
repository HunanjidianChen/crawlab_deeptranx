FROM node:18.20.8-bookworm-slim AS frontend-build

WORKDIR /workspace/frontend

RUN corepack enable \
    && corepack prepare pnpm@7.33.7 --activate

COPY frontend/package.json frontend/pnpm-lock.yaml ./
COPY patches /workspace/patches
RUN pnpm install --frozen-lockfile

COPY frontend ./
RUN pnpm typecheck \
    && pnpm build

FROM crawlabteam/crawlab:0.6.3@sha256:9dbe97240ba2670ce49fd1be5d557b59653e602d8fa29a71c9e05b26c557193b

LABEL org.opencontainers.image.title="DeepTranX Crawlab" \
      org.opencontainers.image.version="0.1.0-crawlab0.6.3" \
      org.opencontainers.image.description="DeepTranX branded frontend on Crawlab 0.6.3" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.source="local"

ENV VIRTUAL_ENV=/opt/crawlab-python \
    PATH=/opt/crawlab-python/bin:${PATH} \
    PYTHONNOUSERSITE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

COPY deploy/requirements-spider.txt /tmp/requirements-spider.txt

RUN python3.10 -m pip install --no-cache-dir virtualenv==20.26.6 \
    && python3.10 -m virtualenv "${VIRTUAL_ENV}" \
    && python -m pip install --no-cache-dir -r /tmp/requirements-spider.txt \
    && rm -f /tmp/requirements-spider.txt \
    && mkdir -p /var/log/crawlab /data/exports/bhol

COPY --from=frontend-build /workspace/frontend/dist /app/dist
COPY deploy/nginx/crawlab.conf /etc/nginx/conf.d/crawlab.conf
COPY deploy/docker-init-deeptranx.sh /app/bin/docker-init-deeptranx.sh

EXPOSE 8080

CMD ["/bin/bash", "/app/bin/docker-init-deeptranx.sh"]
