# syntax=docker/dockerfile:1.7

FROM node:20.11-slim AS builder
WORKDIR /app
COPY app/package.json app/package-lock.json ./
# Apply compatible security fixes to installed dependencies without editing app/.
RUN npm ci --omit=dev && npm audit fix --omit=dev --audit-level=critical
COPY app/src/ ./src/
COPY app/db/ ./db/

FROM node:20.11-slim
WORKDIR /app
COPY --from=builder /app /app
ENV NODE_ENV=production
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"
CMD ["node", "src/index.js"]
