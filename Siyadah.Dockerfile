FROM oven/bun:1.3.10 AS base
WORKDIR /usr/src/app

# تثبيت الأدوات اللازمة لبناء المكتبات البرمجية (Python و C++)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# نسخ المشروع بالكامل
COPY . .

# التثبيت (الآن سينجح لأن Python موجود لبناء isolated-vm)
RUN bun install

# بناء الأجزاء السيادية
RUN npx turbo run build --filter=api --filter=worker

ENV NODE_ENV=production
ENV AP_EXECUTION_MODE=UNSANDBOXED
ENV AP_SANDBOX_MEMORY_LIMIT=1024

EXPOSE 3000
CMD ["node", "packages/server/api/dist/index.js"]
