FROM oven/bun:1.3-alpine AS builder

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY tsconfig.json ./
COPY src ./src
RUN bun run build

FROM oven/bun:1.3-alpine AS runner

RUN apk add --no-cache chromium && \
    mkdir -p /data/chrome && \
    chown -R bun:bun /data

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --production
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=3000 \
    LECLERC_CHROME_PATH=chromium-browser \
    LECLERC_CHROME_PROFILE_DIR=/data/chrome \
    LECLERC_HEADLESS=true

USER bun

EXPOSE 3000

CMD ["bun", "dist/index.js"]
