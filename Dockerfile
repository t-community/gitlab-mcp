FROM node:22.22.3-alpine3.22 AS builder

COPY . /app
COPY tsconfig.json /tsconfig.json

WORKDIR /app

RUN --mount=type=cache,target=/root/.npm npm install

RUN --mount=type=cache,target=/root/.npm-production npm ci --ignore-scripts --omit-dev

FROM node:22.22.3-alpine3.22 AS release

WORKDIR /app

RUN apk upgrade --no-cache openssl

COPY --from=builder /app/build /app/build
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

ENV NODE_ENV=production

EXPOSE 3002

RUN npm ci --ignore-scripts --omit-dev

USER node

ENTRYPOINT ["node", "build/index.js"]
