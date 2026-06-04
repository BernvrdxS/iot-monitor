#!/bin/bash

LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/08_usuarios_permissoes_$(date +%Y-%m-%d).log"

configurar_permissoes() {

    echo "Configuração iniciada em $(date)" | tee -a $LOG_FILE

    groupadd -f iot_ops

    if ! id sensor_user >/dev/null 2>&1; then
        useradd -m -g iot_ops sensor_user
    fi

    mkdir -p /app/iot/sensores
    mkdir -p /app/iot/coletas
    mkdir -p /app/iot/alertas

    chown -R sensor_user:iot_ops /app/iot

    chmod 750 /app/iot
    chmod 750 /app/iot/sensores
    chmod 750 /app/iot/coletas
    chmod 750 /app/iot/alertas
    chmod 750 /app/iot/backups
    chmod 750 /app/iot/logs

    echo "Grupo criado: iot_ops" | tee -a $LOG_FILE
    echo "Usuário criado: sensor_user" | tee -a $LOG_FILE
    echo "Permissões aplicadas com sucesso" | tee -a $LOG_FILE
}

configurar_permissoes