FROM node:20-alpine3.18

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PASSWORD=password

WORKDIR /home/app

COPY . .

CMD ["node", "app/server.js"]
