FROM node:22-bookworm-slim

# Установка зависимостей для Chromium
ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN apt-get update && \
    apt-get install -y wget gnupg && \
    apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
        libgtk2.0-0 libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2 && \
    apt-get install -y chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Установка проекта
WORKDIR /project

# Копируем package.json и устанавливаем зависимости
COPY package.json /project/package.json
RUN npm install

# Копируем конфигурацию TypeScript и исходные файлы
COPY tsconfig.json /project/tsconfig.json
COPY src/ /project/src

# Собираем проект
RUN npm run build || (echo "=== BUILD FAILED ===" && ls -la && cat /root/.npm/_logs/* || true)

# Устанавливаем переменную окружения
ENV DOCKER_CONTAINER=true

# Проброс портов
EXPOSE 3001
EXPOSE 3002

# Запуск приложения
ENTRYPOINT ["node", "dist/main.js"]
