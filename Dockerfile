FROM node:16-alpine as build

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 9000

RUN npm install nexe -g

RUN [ "nexe", "/usr/src/app/index.js", "--build", "-o test.exe", "--verbose" ]

FROM alpine
RUN apk add --no-cache libstdc++ libgcc
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/test.exe test.exe

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]

EXPOSE 9000
CMD ["./test.exe"]