FROM oven/bun:1.3.10-slim AS base
WORKDIR /usr/src/app

# نسخ كل ملفات المشروع أولاً لضمان وجود السياق الكامل
COPY . .

# التثبيت بدون frozen-lockfile لتجنب تعارض الـ Checksum
RUN bun install

# بناء الأجزاء السيادية
RUN npx turbo run build --filter=api --filter=worker

ENV NODE_ENV=production
ENV AP_EXECUTION_MODE=UNSANDBOXED
ENV AP_SANDBOX_MEMORY_LIMIT=1024

EXPOSE 3000
CMD ["node", "packages/server/api/dist/index.js"]
