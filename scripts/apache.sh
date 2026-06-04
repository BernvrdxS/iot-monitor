LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/02_apache_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

registrar_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

instalar_apache() {
    registrar_log "====== INSTALAÇÃO DO APACHE - IoT Monitor ======"

    if command -v apache2 &>/dev/null; then
        registrar_log "[INFO] Apache já está instalado. Pulando instalação."
    else
        registrar_log "Instalando apache2..."
        apt-get update -y >> "$LOG_FILE" 2>&1
        apt-get install -y apache2 curl >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            registrar_log "[OK] Apache instalado com sucesso."
        else
            registrar_log "[ERRO] Falha na instalação do Apache."
            exit 1
        fi
    fi

    registrar_log "Verificando curl (utilizado para testes de conectividade dos sensores IoT)..."
    if ! command -v curl &>/dev/null; then
        apt-get install -y curl >> "$LOG_FILE" 2>&1
        registrar_log "[OK] curl instalado."
    else
        registrar_log "[OK] curl já disponível."
    fi
}

# Função: inicia o serviço Apache
iniciar_apache() {
    registrar_log "Iniciando serviço Apache..."

    # Em containers Docker o apache2ctl é utilizado diretamente
    if apache2ctl start >> "$LOG_FILE" 2>&1 || service apache2 start >> "$LOG_FILE" 2>&1; then
        registrar_log "[OK] Apache iniciado."
    else
        registrar_log "[INFO] Apache pode já estar em execução ou gerenciado pelo container."
    fi
}

verificar_apache() {
    registrar_log "Verificando status do Apache..."

    if pgrep -x apache2 > /dev/null || pgrep -x httpd > /dev/null; then
        registrar_log "[OK] Apache está em execução."
        echo "✔ Apache está ativo e servindo o dashboard IoT Monitor."
    else
        registrar_log "[ALERTA] Apache não está em execução."
        echo "⚠ Apache não está rodando. Execute: apache2ctl start"
    fi
}

versao_apache() {
    local versao
    versao=$(apache2 -v 2>/dev/null | head -1)
    registrar_log "Versão detectada: $versao"
    echo "ℹ Versão do Apache: $versao"
}

instalar_apache
iniciar_apache
verificar_apache
versao_apache

registrar_log "====== CONFIGURAÇÃO APACHE CONCLUÍDA ======"
echo ""
echo "✔ Apache configurado. Dashboard IoT Monitor disponível em http://localhost:8080"
echo "  Log salvo em: $LOG_FILE"