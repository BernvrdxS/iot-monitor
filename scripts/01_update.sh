#!/bin/bash

LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/01_update_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

registrar_log() {
    local mensagem="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensagem" | tee -a "$LOG_FILE"
}

atualizar_sistema() {
    registrar_log "====== INICIANDO ATUALIZAÇÃO DO SISTEMA IoT ======"
    registrar_log "Executando: apt update..."

    if apt-get update -y >> "$LOG_FILE" 2>&1; then
        registrar_log "[OK] Repositórios atualizados com sucesso."
    else
        registrar_log "[ERRO] Falha ao atualizar repositórios."
        exit 1
    fi

    registrar_log "Executando: apt upgrade..."

    if apt-get upgrade -y >> "$LOG_FILE" 2>&1; then
        registrar_log "[OK] Pacotes atualizados com sucesso."
    else
        registrar_log "[ERRO] Falha ao atualizar pacotes."
        exit 1
    fi

    registrar_log "====== ATUALIZAÇÃO CONCLUÍDA COM SUCESSO ======"
    echo ""
    echo "✔ Sistema IoT Monitor atualizado! Log salvo em: $LOG_FILE"
}

atualizar_sistema