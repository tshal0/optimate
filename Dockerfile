FROM node:16 as deps

RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

WORKDIR /app

# Files required by pnpm install
COPY pnpm-lock.yaml ./

RUN pnpm fetch --prod

ADD . ./
RUN pnpm install -r --offline --prod
USER root

CMD ["npm", "run", "start", "api"]
