# Alpine Linux-based, tiny Node container:
FROM node:18-alpine AS base

ADD ./ /opt/app
WORKDIR /opt/app

USER root

RUN rm -rf node_modules \
 && chmod +x ./shell/*.sh 2>/dev/null || true \
 && chown -R node /opt/app

USER node


FROM base AS release

USER root
RUN npm install --only=production \
 && chmod +x ./shell/*.sh \
 #&& apk add --no-cache tini \
 && chown -R node /opt/app

USER node
ENV HOME_DIR=/opt/app \
    NODE_ENV=production \
    PORT=5501

ENTRYPOINT ["/bin/sh", "-c", "cd /opt/app && chmod +x ./shell/*.sh && ./shell/run-db-migraton.sh && node server.js"]


FROM base AS build

USER root
RUN npm install -g nodemon \
 && npm install \
 && chmod +x ./shell/*.sh \
 && chown -R node /opt/app

USER node
