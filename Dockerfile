# Install dependencies only when needed
FROM registry.compony.com/mirror/node:16-alpine AS builder
WORKDIR /app
COPY . .
ARG BUILD_ENV
RUN npm install
RUN npm run build:$BUILD_ENV

FROM registry.compony.com/mirror/node:16-alpine AS runner
LABEL maintainer=" Team "

ARG BUILD_ENV
ENV RUN_ENV=$BUILD_ENV
EXPOSE 3000

WORKDIR /app

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/.env.dev ./.env.dev
COPY --from=builder /app/.env.prod ./.env.prod
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.js ./next.config.js

RUN ls -la

RUN npm i env-cmd -g

ENTRYPOINT "./scripts/run-$RUN_ENV.sh"
