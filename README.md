# Trabalho 03 — Linux, Shell Script e Automação Operacional
### IoT Monitor — Sistema de Monitoramento de Sensores

---

##  Tema

**Monitoramento de Sensores IoT**

---

## Descrição do Cenário

Este projeto simula um ambiente operacional real de **DevOps e Cloud Computing**, onde um profissional júnior é responsável por administrar um servidor Linux utilizado pelo sistema **IoT Monitor**.

O ambiente é executado dentro de um container **Ubuntu Server 22.04** via Docker. Dentro dele, scripts Shell automatizam tarefas como atualização do sistema, instalação e validação do Apache, criação de estrutura de diretórios temática para sensores IoT, backup de dados, deploy do dashboard estático, monitoramento de recursos, controle de usuários e permissões, e geração de relatórios operacionais.

O site estático servido pelo Apache exibe o dashboard do IoT Monitor — interface web para visualização de sensores e leituras.

---

## Tecnologias Utilizadas

| Tecnologia          | Finalidade                                    |
|---------------------|-----------------------------------------------|
| Linux Ubuntu 22.04  | Sistema operacional base do container         |
| Docker              | Containerização do ambiente Linux             |
| Docker Compose      | Orquestração do container                     |
| Apache 2            | Servidor web para o dashboard IoT             |
| Shell Script (Bash) | Automação de tarefas operacionais             |
| GitHub              | Versionamento e entrega do projeto            |
| DockerHub           | Publicação da imagem Docker                   |

---

## Arquitetura do Ambiente

```
┌──────────────────────────────────────────┐
│          trabalho03-linux                │
│          Ubuntu Server 22.04             │
│                                          │
│  Apache :80 ──► http://localhost:8080    │
│                                          │
│  /scripts/    ← scripts Shell            │
│  /source/     ← arquivos estáticos       │
│  /iot/        ← dados do IoT             │
│    ├── sensores/                         │
│    ├── coletas/                          │
│    ├── alertas/                          │
│    ├── logs/                             │
│    └── backups/                          │
│  /var/www/html/   ← publicação Apache    │
└──────────────────────────────────────────┘
         │                    │
   Volume iot_data       Volumes locais
   (dados /iot)          logs/ backups/
                         scripts/ source/
```

- O container **trabalho03-linux** executa Ubuntu com Apache
- Os scripts Shell estão em `/scripts/` dentro do container
- O Apache serve os arquivos de `/var/www/html/`
- Logs e backups são persistidos via volumes mapeados para o host

---

## Estrutura do Projeto

```
iot-monitor/
├── Dockerfile                     # Imagem Ubuntu 22.04 + Apache
├── docker-compose.yml             # Orquestração do container
├── README.md                      # Esta documentação
├── scripts/
│   ├── 01_update.sh               # Atualização do sistema
│   ├── 02_apache.sh               # Instalação e validação do Apache
│   ├── 03_estrutura.sh            # Estrutura de diretórios IoT
│   ├── 04_backup.sh               # Backup automatizado
│   ├── 05_deploy.sh               # Deploy do dashboard no Apache
│   ├── 06_processos.sh            # Gerenciamento de processos
│   ├── 07_monitoramento.sh        # Monitoramento CPU/RAM/Disco/Apache
│   ├── 08_usuarios_permissoes.sh  # Usuários, grupos e permissões
│   ├── 09_relatorio.sh            # Relatório operacional completo
│   └── menu.sh                    # Menu principal interativo
├── source/
│   ├── index.html                 # Dashboard IoT Monitor
│   ├── sobre.html                 # Página sobre o sistema
│   └── assets/                    # Recursos estáticos
├── backups/                       # Backups .tar.gz gerados
├── logs/                          # Logs de execução dos scripts
└── evidencias/                    # Prints e evidências de execução
```

---

## Como Executar o Projeto

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) instalado e em execução
- [Docker Compose](https://docs.docker.com/compose/) disponível (incluído no Docker Desktop)
- Git instalado

### Passo a Passo

**1. Clone o repositório**
```bash
git clone https://github.com/BernvrdxS/iot-monitor.git
cd iot-monitor
```

**2. Suba o container com build**
```bash
docker compose up -d --build
```

**3. Confirme que o container está rodando**
```bash
docker ps
```
Deve aparecer `trabalho03-linux` com status `Up`.

**4. Acesse o container Linux**
```bash
docker exec -it trabalho03-linux bash
```

**5. Dentro do container, vá até os scripts e dê permissão**
```bash
cd /app/scripts
chmod +x *.sh
```

**6. Execute o menu principal**
```bash
./menu.sh
```

---

## Como Acessar o Apache no Navegador

Após executar o deploy (`./05_deploy.sh` dentro do container), acesse:

```
http://localhost:8080
```

O dashboard do **IoT Monitor** será exibido, servido pelo Apache.

---

## Scripts Disponíveis

| Script                      | Descrição                                                      |
|-----------------------------|----------------------------------------------------------------|
| `01_update.sh`              | Executa `apt update` e `apt upgrade`, registra log            |
| `02_apache.sh`              | Instala, inicia e valida o Apache; exibe versão instalada      |
| `03_estrutura.sh`           | Cria `/app/iot/sensores`, `/coletas`, `/alertas`, `/logs` etc  |
| `04_backup.sh`              | Gera `backup_iot_YYYY-MM-DD_HH-MM.tar.gz` em `backups/`       |
| `05_deploy.sh`              | Copia `source/` para `/var/www/html`, valida o `index.html`    |
| `06_processos.sh`           | Lista, busca e encerra processos por nome ou PID               |
| `07_monitoramento.sh`       | Exibe CPU, RAM, disco e status do Apache com alertas           |
| `08_usuarios_permissoes.sh` | Cria grupo `iot_ops`, usuário `sensor_user` e aplica `chown`   |
| `09_relatorio.sh`           | Gera relatório em `logs/relatorio_execucao.txt`                |
| `menu.sh`                   | Menu interativo que integra todos os scripts acima             |

---

## Como Executar Cada Script

Todos os comandos abaixo devem ser executados **dentro do container**:

```bash
docker exec -it trabalho03-linux bash
cd /app/scripts
```

```bash
# Atualizar sistema
./01_update.sh

# Instalar e validar Apache
./02_apache.sh

# Criar estrutura de diretórios IoT
./03_estrutura.sh

# Realizar backup dos dados
./04_backup.sh

# Deploy do dashboard no Apache
./05_deploy.sh

# Gerenciar processos
./06_processos.sh listar
./06_processos.sh buscar apache
./06_processos.sh matar 1234

# Monitorar sistema
./07_monitoramento.sh

# Configurar usuários e permissões
./08_usuarios_permissoes.sh

# Gerar relatório operacional
./09_relatorio.sh
```

---

## Como Executar o Menu Principal

```bash
docker exec -it trabalho03-linux bash
cd /app/scripts
./menu.sh
```

O menu exibirá:

```
╔════════════════════════════════════════╗
║     MENU DEVOPS CLOUD — IoT Monitor    ║
║     Criado por: Bernardo Santos        ║
║     Instituição: Unidavi               ║
║     Tema: Monitoramento de Sensores    ║
╚════════════════════════════════════════╝

1 - Atualizar sistema
2 - Instalar Apache
3 - Criar estrutura do projeto
4 - Realizar backup
5 - Fazer deploy
6 - Ver processos
7 - Monitorar sistema
8 - Configurar usuários e permissões
9 - Gerar relatório
0 - Sair
```

---

## Portas Utilizadas

| Serviço         | Porta interna | Porta externa |
|-----------------|---------------|---------------|
| Apache (Ubuntu) | 80            | 8080          |

---

## Docker Compose — Detalhes

O `docker-compose.yml` define:

- **Serviço `linux`**: container Ubuntu 22.04 com Apache
- **Volume `iot_data`**: persiste os dados do IoT entre reinicializações
- **Volumes locais mapeados**: `scripts/`, `source/`, `logs/`, `backups/` e `evidencias/` sincronizados com o host
- **Porta 8080**: expõe o Apache para acesso pelo navegador

---

## DockerHub

A imagem está publicada em:

```
docker pull bernardosantos777/iot-monitor:trabalho03
```

🔗 https://hub.docker.com/r/bernardosantos777/iot-monitor

---

## Dificuldades Encontradas

- **Reorganização da estrutura de arquivos:** os arquivos estavam soltos na raiz, sendo necessário criar subpastas (`scripts/`, `source/`) para que o Docker encontrasse os arquivos corretamente.
- **Permissões dos scripts:** os scripts precisam de `chmod +x` explícito dentro do container antes de serem executados.
- **Conflito de portas:** verificar com `docker ps` se a porta 8080 está disponível antes de subir os containers.
- **Editor Vim no Git:** ao executar `git pull`, o terminal abriu o Vim para confirmar o merge, resolvido com `:wq`.
