#!/bin/bash

LOG_DIR="/app/iot/logs"
LOG_FILE="$LOG_DIR/07_monitoramento_$(date +%Y-%m-%d).log"

monitorar_sistema() {

    echo "==============================" | tee -a $LOG_FILE
    echo "Monitoramento IoT" | tee -a $LOG_FILE
    echo "Data: $(date)" | tee -a $LOG_FILE
    echo "==============================" | tee -a $LOG_FILE

    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    MEMORIA=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
    DISCO=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    echo "Uso de CPU: ${CPU}%" | tee -a $LOG_FILE
    echo "Uso de Memória: ${MEMORIA}%" | tee -a $LOG_FILE
    echo "Uso de Disco: ${DISCO}%" | tee -a $LOG_FILE

    if [ "$MEMORIA" -gt 80 ]; then
        echo "[ALERTA] Uso de memória acima de 80%" | tee -a $LOG_FILE
    fi

    if [ "$DISCO" -gt 80 ]; then
        echo "[ALERTA] Uso de disco acima de 80%" | tee -a $LOG_FILE
    fi

    if [ "${CPU%.*}" -gt 80 ]; then
        echo "[ALERTA] Uso de CPU acima de 80%" | tee -a $LOG_FILE
    fi

    if pgrep apache2 > /dev/null; then
        echo "[OK] Apache em execução" | tee -a $LOG_FILE
    else
        echo "[ALERTA] Apache não está em execução" | tee -a $LOG_FILE
    fi
}

monitorar_sistema