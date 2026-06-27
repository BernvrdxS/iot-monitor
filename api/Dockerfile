# Dockerfile - IoT Monitor API
# Imagem leve baseada em Node.js Alpine, usada apenas para empacotar e
# executar a API REST (não confundir com o Dockerfile do Trabalho 3,
# que monta um ambiente Ubuntu + Apache para os scripts shell).

FROM node:20-alpine

WORKDIR /usr/src/app

# Copia primeiro apenas os manifestos de dependência para aproveitar o
# cache de camadas do Docker: a instalação só roda de novo se o
# package.json/package-lock.json mudar.
COPY package*.json ./

RUN npm ci --omit=dev

# Agora copia o restante do código da API
COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
