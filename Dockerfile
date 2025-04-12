FROM node:22-bookworm-slim

WORKDIR /project

COPY package.json /project/package.json
RUN npm install

COPY tsconfig.json /project/tsconfig.json
COPY src/ /project/src
RUN npm run build

ENV DOCKER_CONTAINER=true

EXPOSE 3001

ENTRYPOINT ["node", "dist/main.js"]
