FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN apt-get update && \
    apt-get install -y chromium && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /project

COPY package.json /project/package.json
COPY tsconfig.json /project/tsconfig.json
COPY src/ /project/src

RUN npm install

RUN echo "=== СОДЕРЖИМОЕ /project ===" && \
    ls -la /project && \
    echo "=== СОДЕРЖИМОЕ /project/src ===" && \
    ls -la /project/src && \
    echo "=== ВСЕ .ts файлы ===" && \
    find /project -name "*.ts"

RUN echo "=== ЗАПУСК npm run build ===" && \
    npm run build || (echo "=== ❌ BUILD FAILED ===" && cat /root/.npm/_logs/* || true)

ENV DOCKER_CONTAINER=true

ENTRYPOINT ["sh", "-c", "\
  if [ \"$MODE\" = \"whatsapp-api\" ]; then \
    node dist/main.js --mode whatsapp-api --api-port 5001; \
  elif [ \"$MODE\" = \"mcp\" ]; then \
    node dist/main.js --mode mcp \
      --transport sse \
      --sse-port 5002 \
      --api-base-url http://whatsappAPI:5001/api \
      --api-key default-api-key; \
  else \
    echo \"❌ Unknown MODE: $MODE\"; exit 1; \
  fi \
"]

