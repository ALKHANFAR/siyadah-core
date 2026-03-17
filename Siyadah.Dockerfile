FROM oven/bun:1.3.10 AS base
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y python3 build-essential git jq curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY . .
ARG CACHEBUST=4

RUN find . -name 'package.json' -not -path '*/node_modules/*' -exec \
    sh -c 'jq "del(.dependencies[\"isolated-vm\"]) | del(.devDependencies[\"isolated-vm\"]) | del(.optionalDependencies[\"isolated-vm\"])" "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;

RUN mkdir -p empty-pkg && \
    echo '{"name":"isolated-vm","version":"0.0.0","main":"index.js"}' > empty-pkg/package.json && \
    echo 'module.exports = new Proxy({}, { get: () => { throw new Error("isolated-vm not available in UNSANDBOXED mode"); } });' > empty-pkg/index.js

RUN bun install
RUN npx turbo run build --filter=api --filter=worker

RUN find packages/server/api/dist -name "*.js" -maxdepth 1 -exec cp {} packages/server/api/dist/server.js \;

ENV NODE_ENV=production
ENV AP_EXECUTION_MODE=UNSANDBOXED
ENV AP_SANDBOX_MEMORY_LIMIT=1024
ENV AP_QUEUE_MODE=MEMORY
ENV AP_DB_TYPE=SQLITE3
ENV AP_SQLITE_DATABASE_PATH=/data/siyadah.db

EXPOSE 3000
CMD ["node", "packages/server/api/dist/server.js"]
