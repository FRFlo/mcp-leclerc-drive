FROM oven/bun:1.3-alpine AS builder

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY tsconfig.json ./
COPY src ./src
RUN bun run build

FROM oven/bun:1.3 AS runner

RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium xvfb fluxbox x11vnc novnc websockify && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/chrome && \
    chown -R bun:bun /data

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --production
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=3000 \
    DISPLAY=:99 \
    LECLERC_CHROME_PATH=chromium \
    LECLERC_CHROME_PROFILE_DIR=/data/chrome \
    LECLERC_HEADLESS=false

USER bun

EXPOSE 3000 6080

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
