#!/bin/bash

ORIGEM="/app/source"
DESTINO="/var/www/html"
LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/05_deploy_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

registrar_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

validar_fonte() {
    if [ ! -d "$ORIGEM" ]; then
        registrar_log "[ERRO] Diretório source/ não encontrado: $ORIGEM"
        echo "✘ Pasta source/ não encontrada. Verifique a estrutura do projeto."
        exit 1
    fi

    if [ ! -f "$ORIGEM/index.html" ]; then
        registrar_log "[ERRO] index.html não encontrado em $ORIGEM"
        echo "✘ index.html ausente em source/. Deploy cancelado."
        exit 1
    fi

    registrar_log "[OK] Arquivos fonte validados em: $ORIGEM"
}

limpar_destino() {
    registrar_log "Limpando diretório de destino: $DESTINO"
    rm -rf "${DESTINO:?}"/*
    registrar_log "[OK] Destino limpo."
}

publicar_arquivos() {
    registrar_log "====== INICIANDO DEPLOY - IoT Monitor Dashboard ======"
    registrar_log "Copiando de $ORIGEM para $DESTINO..."

    cp -r "$ORIGEM"/. "$DESTINO/"

    if [ $? -eq 0 ]; then
        registrar_log "[OK] Arquivos copiados com sucesso."
    else
        registrar_log "[ERRO] Falha ao copiar arquivos."
        exit 1
    fi

    chmod -R 644 "$DESTINO"/*.html 2>/dev/null
    find "$DESTINO" -type d -exec chmod 755 {} \;
    registrar_log "[OK] Permissões ajustadas (644 para arquivos, 755 para diretórios)."
}

validar_deploy() {
    if [ -f "$DESTINO/index.html" ]; then
        registrar_log "[OK] Deploy validado. index.html presente em $DESTINO"
        echo ""
        echo "✔ Deploy realizado com sucesso!"
        echo "  Dashboard IoT Monitor disponível em: http://localhost:8080"
    else
        registrar_log "[ERRO] index.html não encontrado em $DESTINO após deploy."
        echo "✘ Falha na validação do deploy."
        exit 1
    fi
}

listar_publicados() {
    echo ""
    echo "📄 Arquivos publicados no Apache:"
    ls -lh "$DESTINO" 2>/dev/null
    registrar_log "Arquivos publicados: $(ls $DESTINO | tr '\n' ' ')"
}

validar_fonte
limpar_destino
publicar_arquivos
validar_deploy
listar_publicados

registrar_log "====== DEPLOY CONCLUÍDO ======"
echo ""
echo "  Log salvo em: $LOG_FILE"