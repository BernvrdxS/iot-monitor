FROM node:20-alpine

# Metadados da imagem
LABEL maintainer="IoT Monitor App"
LABEL description="Sistema de Monitoramento de Sensores IoT"

# Definir diretório de trabalho dentro do container
WORKDIR /app

# Copiar apenas os arquivos de dependências primeiro (otimização de cache)
COPY package*.json ./

# Instalar dependências de produção
RUN npm install --omit=dev

# Copiar o restante do código da aplicação
COPY . .

# Expor a porta que a aplicação utiliza
EXPOSE 3000

# Healthcheck: verifica se a aplicação está respondendo
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Comando para iniciar a aplicação
CMD ["node", "src/server.js"]
