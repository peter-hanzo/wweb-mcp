FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN apt-get update && \
    apt-get install -y wget gnupg \
      fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
      libxss1 libgtk2.0-0 libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2 \
      chromium-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /project

# Копируем только package.json и tsconfig для кэширования npm install
COPY package.json tsconfig.json /project/

RUN npm install

# Копируем исходники
COPY src/ /project/src

RUN npm run build || (echo "=== ❌ BUILD FAILED ===" && cat /root/.npm/_logs/* || true)

ENV DOCKER_CONTAINER=true

ENTRYPOINT ["sh", "-c", "\
  if [ \"$MODE\" = \"whatsapp-api\" ]; then \
    exec node dist/main.js --mode whatsapp-api --api-port ${API_PORT:-5001}; \
  elif [ \"$MODE\" = \"mcp\" ]; then \
    exec node dist/main.js --mode mcp \
      --transport ${TRANSPORT:-sse} \
      --sse-port ${SSE_PORT:-5002} \
      --api-base-url ${API_BASE_URL:-http://whatsapp-api:5001/api} \
      --api-key ${API_KEY:-default-api-key}; \
  else \
    echo \"❌ Unknown MODE: $MODE\"; exit 1; \
  fi \
"]
