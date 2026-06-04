LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/06_processos_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

registrar_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

listar_processos() {
    registrar_log "Listando processos ativos do sistema IoT..."
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "  PROCESSOS ATIVOS - IoT Monitor"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "═══════════════════════════════════════════════════"
    ps aux --sort=-%cpu | head -20
    echo "═══════════════════════════════════════════════════"
    registrar_log "[OK] Listagem de processos concluída."
}

buscar_processo() {
    local nome="$1"

    if [ -z "$nome" ]; then
        echo "✘ Informe o nome do processo. Exemplo: ./06_processos.sh buscar apache"
        exit 1
    fi

    registrar_log "Buscando processo: $nome"
    echo ""
    echo "🔍 Buscando processo: '$nome'"
    echo "───────────────────────────────────────────────────"

    local resultado
    resultado=$(ps aux | grep -i "$nome" | grep -v grep)

    if [ -n "$resultado" ]; then
        echo "$resultado"
        local quantidade
        quantidade=$(echo "$resultado" | wc -l)
        echo "───────────────────────────────────────────────────"
        echo "✔ $quantidade processo(s) encontrado(s) com o nome '$nome'."
        registrar_log "[OK] Processo '$nome' encontrado ($quantidade instância(s))."
    else
        echo "  Nenhum processo encontrado com o nome '$nome'."
        registrar_log "[INFO] Processo '$nome' não encontrado."
    fi
}

matar_processo() {
    local pid="$1"

    if [ -z "$pid" ]; then
        echo "✘ ERRO DE SEGURANÇA: PID não informado."
        echo "  Uso correto: ./06_processos.sh matar <PID>"
        echo "  Exemplo:     ./06_processos.sh matar 1234"
        registrar_log "[SEGURANÇA] Tentativa de matar processo sem PID informado. Operação bloqueada."
        exit 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "✘ PID inválido: '$pid'. Informe apenas números."
        registrar_log "[ERRO] PID inválido fornecido: $pid"
        exit 1
    fi

    if ! kill -0 "$pid" 2>/dev/null; then
        echo "✘ Processo com PID $pid não encontrado ou já encerrado."
        registrar_log "[INFO] PID $pid não existe ou já foi encerrado."
        exit 1
    fi

    local info
    info=$(ps -p "$pid" -o comm= 2>/dev/null)
    echo ""
    echo "⚠  Encerrando processo:"
    echo "   PID  : $pid"
    echo "   Nome : $info"
    echo ""

    kill "$pid" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✔ Processo $pid ($info) encerrado com sucesso."
        registrar_log "[OK] Processo $pid ($info) encerrado."
    else
        echo "✘ Falha ao encerrar processo $pid. Verifique as permissões."
        registrar_log "[ERRO] Falha ao encerrar processo $pid."
    fi
}

exibir_ajuda() {
    echo ""
    echo "Uso: ./06_processos.sh <ação> [parâmetro]"
    echo ""
    echo "Ações disponíveis:"
    echo "  listar              Lista todos os processos ativos"
    echo "  buscar <nome>       Busca processo pelo nome"
    echo "  matar  <PID>        Encerra processo pelo PID"
    echo ""
    echo "Exemplos:"
    echo "  ./06_processos.sh listar"
    echo "  ./06_processos.sh buscar apache"
    echo "  ./06_processos.sh matar 1234"
}

ACAO="$1"
PARAMETRO="$2"

case "$ACAO" in
    listar)
        listar_processos
        ;;
    buscar)
        buscar_processo "$PARAMETRO"
        ;;
    matar)
        matar_processo "$PARAMETRO"
        ;;
    *)
        exibir_ajuda
        ;;
esac