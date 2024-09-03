Dockerfile backend

FROM node:22

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build
RUN npm run prisma:generate

EXPOSE 8080
CMD [ "npm", "start" ]



dockerfile frontend

FROM node:22

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

CMD [ "npm", "start" ]
