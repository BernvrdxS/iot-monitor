#!/bin/bash

mkdir -p /app/logs

RELATORIO="/app/logs/relatorio_execucao.txt"

gerar_relatorio() {

    echo "==================================" > "$RELATORIO"
    echo "RELATÓRIO OPERACIONAL IoT MONITOR" >> "$RELATORIO"
    echo "==================================" >> "$RELATORIO"
    echo "Data: $(date)" >> "$RELATORIO"
    echo "" >> "$RELATORIO"

    echo "Espaço em Disco" >> "$RELATORIO"
    df -h >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Uso dos Diretórios" >> "$RELATORIO"
    du -sh /app/* 2>/dev/null >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Status Apache" >> "$RELATORIO"

    if pgrep apache2 >/dev/null; then
        echo "Apache: ATIVO" >> "$RELATORIO"
    else
        echo "Apache: INATIVO" >> "$RELATORIO"
    fi

    echo "" >> "$RELATORIO"
    echo "Últimos Backups" >> "$RELATORIO"
    ls -lh /app/backups 2>/dev/null >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Últimos Logs" >> "$RELATORIO"
    ls -lh /app/logs 2>/dev/null >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Arquivos Publicados" >> "$RELATORIO"
    ls -lh /var/www/html >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Usuários do Sistema" >> "$RELATORIO"
    getent passwd sensor_user >> "$RELATORIO"

    echo "" >> "$RELATORIO"
    echo "Permissões Diretórios IoT" >> "$RELATORIO"
    ls -ld /app/iot/* >> "$RELATORIO"

    echo "Relatório gerado com sucesso."
}

gerar_relatorio