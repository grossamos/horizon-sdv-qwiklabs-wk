FROM node:latest
RUN apt update -y && apt install vim curl jq -y
WORKDIR /home/node
ADD package.json ./
ADD keycloak.mjs ./
ADD configure.sh ./
ADD secret.json ./
ADD secure.config ./
RUN chmod +x configure.sh
USER node
CMD ["/bin/sh", "-c", "/home/node/configure.sh"]
