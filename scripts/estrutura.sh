LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/03_estrutura_$(date +%Y-%m-%d).log"
BASE_DIR="/app/iot"

mkdir -p "$LOG_DIR"

registrar_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

limpar_estrutura_antiga() {
    registrar_log "Limpando estruturas temporárias antigas..."

    for dir in sensores/temp coletas/temp alertas/resolvidos; do
        if [ -d "$BASE_DIR/$dir" ]; then
            rm -rf "${BASE_DIR:?}/$dir"
            registrar_log "[OK] Removido: $BASE_DIR/$dir"
        fi
    done
}

criar_estrutura_iot() {
    registrar_log "====== CRIANDO ESTRUTURA DE DIRETÓRIOS - IoT Monitor ======"

    local diretorios=(
        "$BASE_DIR/sensores/temperatura"
        "$BASE_DIR/sensores/umidade"
        "$BASE_DIR/sensores/pressao"
        "$BASE_DIR/sensores/co2"
        "$BASE_DIR/coletas/historico"
        "$BASE_DIR/coletas/tempo_real"
        "$BASE_DIR/alertas/criticos"
        "$BASE_DIR/alertas/avisos"
        "$BASE_DIR/alertas/resolvidos"
        "$BASE_DIR/logs/sistema"
        "$BASE_DIR/logs/sensores"
        "$BASE_DIR/backups"
        "$BASE_DIR/publicacao"
        "/var/log/iot"
    )

    for dir in "${diretorios[@]}"; do
        mkdir -p "$dir"
        registrar_log "[OK] Criado: $dir"
        echo "  ✔ $dir"
    done
}

criar_arquivos_iniciais() {
    registrar_log "Criando arquivos iniciais do sistema IoT..."

    cat > "$BASE_DIR/sensores/sensores.conf" <<EOF
# Configuração dos Sensores IoT Monitor
# Gerado automaticamente em: $(date)
SENSOR_TEMP_MAX=80
SENSOR_UMID_MAX=90
SENSOR_PRESSAO_MAX=1100
SENSOR_CO2_MAX=1000
INTERVALO_COLETA=60
EOF
    registrar_log "[OK] Arquivo sensores.conf criado."

    cat > "$BASE_DIR/coletas/historico/coletas.log" <<EOF
# Log de Coletas - IoT Monitor
# Inicializado em: $(date)
# Formato: [timestamp] sensor_id | tipo | valor | status
EOF
    registrar_log "[OK] Arquivo coletas.log criado."

    cat > "$BASE_DIR/alertas/alertas_ativos.txt" <<EOF
# Alertas Ativos - IoT Monitor
# Última atualização: $(date)
# Nenhum alerta ativo no momento.
EOF
    registrar_log "[OK] Arquivo alertas_ativos.txt criado."

    echo ""
    echo "✔ Arquivos iniciais criados com sucesso."
}

exibir_estrutura() {
    registrar_log "Estrutura de diretórios criada:"
    echo ""
    echo "📁 Estrutura do IoT Monitor:"
    find "$BASE_DIR" -maxdepth 3 -not -path '*/\.*' | sort | \
        sed -e "s|$BASE_DIR||" -e 's|[^/]*/|  |g' -e 's|  \([^/]\)|  └─ \1|'
    echo ""
}

limpar_estrutura_antiga
criar_estrutura_iot
criar_arquivos_iniciais
exibir_estrutura

registrar_log "====== ESTRUTURA IoT CRIADA COM SUCESSO ======"
echo "✔ Estrutura de diretórios do IoT Monitor pronta!"
echo "  Log salvo em: $LOG_FILE"