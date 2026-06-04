FROM ubuntu:22.04

# Evita prompts interativos durante apt install
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza pacotes base e instala dependências essenciais
RUN apt-get update && apt-get install -y \
    apache2 \
    curl \
    vim \
    procps \
    tar \
    gzip \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Cria estrutura de diretórios do projeto IoT
RUN mkdir -p \
    /app/iot/sensores \
    /app/iot/coletas \
    /app/iot/alertas \
    /app/iot/logs \
    /app/iot/backups \
    /app/iot/publicacao \
    /app/scripts \
    /var/log/iot

# Copia os scripts para dentro do container
COPY scripts/ /app/scripts/

# Copia arquivos estáticos do site para o Apache
COPY source/ /var/www/html/

# Garante permissão de execução em todos os scripts
RUN chmod +x /app/scripts/*.sh

# Expõe a porta do Apache
EXPOSE 80

# Inicia o Apache em primeiro plano
CMD ["apache2ctl", "-D", "FOREGROUND"]