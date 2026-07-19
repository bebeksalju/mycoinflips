FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --production

COPY . .

# We need docker client to run `docker logs` commands inside child_process
RUN apk add --no-cache docker-cli bash git

CMD [ "npm", "start" ]
