FROM node:22-bookworm-slim

# Убираем интерактивный режим и настраиваем Puppeteer
ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Устанавливаем Chromium
RUN apt-get update && \
    apt-get install -y chromium && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /project

# Копируем package & tsconfig
COPY package.json tsconfig.json /project/

# Копируем исходники
COPY src/ /project/src

# Устанавливаем зависимости и билдим
RUN npm install

# Диагностика содержимого (опционально)
RUN echo "=== СОДЕРЖИМОЕ /project ===" && ls -la /project \
 && echo "=== СОДЕРЖИМОЕ /project/src ===" && ls -la /project/src \
 && echo "=== ВСЕ .ts файлы ===" && find /project -name "*.ts"

RUN echo "=== ЗАПУСК npm run build ===" \
 && npm run build \
    || (echo "=== ❌ BUILD FAILED ===" && cat /root/.npm/_logs/* || true)

# Пометка контейнера
ENV DOCKER_CONTAINER=true

# По умолчанию запускаем API (можно переопределить через `docker-compose command:`)
CMD ["node", "dist/main.js", "--mode", "whatsapp-api", "--api-port", "5001"]
