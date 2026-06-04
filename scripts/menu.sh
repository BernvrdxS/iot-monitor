#!/bin/bash

while true
do

clear

echo "===================================="
echo "Criado por: Bernardo Santos"
echo "Instituição: UNIDAVI"
echo "Tema: Plataforma de Monitoramento IoT"
echo "===================================="
echo ""
echo "===== MENU DEVOPS CLOUD ====="
echo "1 - Atualizar sistema"
echo "2 - Instalar Apache"
echo "3 - Criar estrutura IoT"
echo "4 - Realizar backup"
echo "5 - Fazer deploy"
echo "6 - Gerenciar processos"
echo "7 - Monitorar sistema"
echo "8 - Configurar usuários e permissões"
echo "9 - Gerar relatório"
echo "0 - Sair"
echo ""

read -p "Escolha uma opção: " opcao

case $opcao in

1) ./01_update.sh ;;
2) ./02_apache.sh ;;
3) ./03_estrutura.sh ;;
4) ./04_backup.sh ;;
5) ./05_deploy.sh ;;
6) ./06_processos.sh listar ;;
7) ./07_monitoramento.sh ;;
8) ./08_usuarios_permissoes.sh ;;
9) ./09_relatorio.sh ;;
0) exit ;;
*) echo "Opção inválida" ;;

esac

echo ""
read -p "Pressione ENTER para continuar"

done