FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Установка зависимостей (включая Chromium)
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
        libgtk2.0-0 libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2 && \
    apt-get install -y chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Установка проекта
WORKDIR /project

COPY package.json /project/package.json
RUN npm install

COPY tsconfig.json /project/tsconfig.json
COPY src/ /project/src
RUN npm run build

ENV DOCKER_CONTAINER=true

# Проброс порта API (изменяй, если порт другой)
EXPOSE 3001

# Запуск приложения
ENTRYPOINT ["node", "dist/main.js"]
