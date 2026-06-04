#!/bin/bash

ORIGEM="/app/iot"
DESTINO="/app/iot/backups"
LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/04_backup_$(date +%Y-%m-%d).log"
DATA_HORA=$(date +%Y-%m-%d_%H-%M)
NOME_BACKUP="backup_iot_monitor_${DATA_HORA}.tar.gz"
CAMINHO_BACKUP="$DESTINO/$NOME_BACKUP"

mkdir -p "$DESTINO" "$LOG_DIR"

registrar_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

validar_origem() {
    if [ ! -d "$ORIGEM" ]; then
        registrar_log "[ERRO] Diretório de origem não encontrado: $ORIGEM"
        echo "✘ Diretório de origem inexistente. Execute primeiro: ./03_estrutura.sh"
        exit 1
    fi
    registrar_log "[OK] Origem validada: $ORIGEM"
}

gerar_backup() {
    registrar_log "====== INICIANDO BACKUP - IoT Monitor ======"
    registrar_log "Origem:  $ORIGEM"
    registrar_log "Destino: $CAMINHO_BACKUP"

    tar --exclude="$DESTINO" -czf "$CAMINHO_BACKUP" -C "$(dirname $ORIGEM)" "$(basename $ORIGEM)" 2>> "$LOG_FILE"

    if [ $? -eq 0 ]; then
        registrar_log "[OK] Backup criado com sucesso: $NOME_BACKUP"
    else
        registrar_log "[ERRO] Falha ao criar backup."
        exit 1
    fi
}

validar_backup() {
    if [ -f "$CAMINHO_BACKUP" ]; then
        local tamanho
        tamanho=$(du -sh "$CAMINHO_BACKUP" | cut -f1)
        registrar_log "[OK] Backup validado. Arquivo: $NOME_BACKUP | Tamanho: $tamanho"
        echo ""
        echo "✔ Backup gerado com sucesso!"
        echo "  Arquivo : $NOME_BACKUP"
        echo "  Tamanho : $tamanho"
        echo "  Local   : $CAMINHO_BACKUP"
    else
        registrar_log "[ERRO] Arquivo de backup não encontrado após criação."
        echo "✘ Falha na validação do backup."
        exit 1
    fi
}

listar_backups() {
    echo ""
    echo "📦 Últimos backups do IoT Monitor:"
    ls -lht "$DESTINO"/*.tar.gz 2>/dev/null | head -5 || echo "  Nenhum backup anterior encontrado."
}

validar_origem
gerar_backup
validar_backup
listar_backups

registrar_log "====== BACKUP CONCLUÍDO ======"
echo ""
echo "  Log salvo em: $LOG_FILE"