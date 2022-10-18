FROM node:16-alpine as builder
WORKDIR /app
COPY package.json .
COPY tsconfig.json .
COPY ./src ./src
RUN yarn install --frozen-lockfile
RUN yarn build

FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN yarn install --frozen-lockfile 
COPY tsconfig.json .
COPY --from=builder /app/dist ./dist
RUN echo "안녕하심까??"
CMD yarn start
