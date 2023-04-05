FROM --platform=linux/amd64 node:16 as build

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 9000

RUN apt-get -y update && apt-get -y install python3

RUN npm install nexe -g

RUN [ "nexe", "-t linux-x64", "index.js", "--build", "-o test", "--python python3", "--verbose" ]

FROM alpine
RUN apk add --no-cache libstdc++ libgcc
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/test test

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]

EXPOSE 9000
CMD ["./test"]
