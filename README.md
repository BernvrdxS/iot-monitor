# 📡 IoT Monitor — Sistema de Monitoramento de Sensores

Sistema web para monitoramento em tempo real de sensores IoT, com cadastro, consulta, atualização e remoção de sensores e suas leituras. Desenvolvido como aplicação multicontainer com Docker e Docker Compose.

---

## 📋 Descrição da Aplicação

O **IoT Monitor** permite:
- **Cadastrar sensores** IoT com nome, tipo, localização e unidade de medida
- **Registrar leituras** de cada sensor ao longo do tempo
- **Monitorar em dashboard** o status de cada sensor em tempo real
- **Gerenciar** todas as informações via interface web responsiva

O sistema classifica automaticamente cada leitura em três status:
- 🟢 **Normal** — valor até 60
- 🟡 **Warning** — valor entre 61 e 80
- 🔴 **Critical** — valor acima de 80

---

## 🛠️ Tecnologias Utilizadas

| Camada      | Tecnologia          |
|-------------|---------------------|
| Backend     | Node.js + Express   |
| Frontend    | HTML / CSS / JS     |
| Banco       | PostgreSQL 15       |
| Container   | Docker + Docker Compose |
| Linguagem   | JavaScript (ES6+)   |

---

## 🏗️ Arquitetura Utilizada

```
┌─────────────────────────────────────┐
│         iot_network (bridge)        │
│                                     │
│  ┌────────────────┐  ┌───────────┐  │
│  │   iot_app      │  │  iot_db   │  │
│  │  Node.js:3000  │──│ Postgres  │  │
│  │  (container)   │  │  :5432    │  │
│  └────────────────┘  └───────────┘  │
│          │                  │       │
└──────────│──────────────────│───────┘
           │                  │
      Porta 3000         Volume pgdata
     (navegador)       (dados persistidos)
```

- O container **iot_app** serve o frontend e a API REST
- O container **iot_db** executa o PostgreSQL isolado
- Ambos comunicam-se pela rede interna **iot_network**
- Os dados do banco são persistidos no volume **iot_pgdata**

---

## ▶️ Instruções de Execução

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) instalado
- [Docker Compose](https://docs.docker.com/compose/) instalado (já incluído no Docker Desktop)

### Passo a passo

**1. Clone o repositório**
```bash
git clone https://github.com/SEU_USUARIO/iot-monitor.git
cd iot-monitor
```

**2. (Opcional) Configure as variáveis de ambiente**
```bash
cp .env.example .env
# Edite o .env se quiser alterar senhas ou portas
```

**3. Suba todos os containers**
```bash
docker compose up -d
```

**4. Acesse a aplicação**

Abra o navegador em: [http://localhost:3000](http://localhost:3000)

**5. Para parar os containers**
```bash
docker compose down
```

**Para parar E remover os dados (limpar tudo):**
```bash
docker compose down -v
```

---

## 🔧 Comandos Úteis

```bash
# Ver containers em execução
docker ps

# Ver logs da aplicação
docker logs iot_app

# Ver logs do banco
docker logs iot_db

# Ver volumes criados
docker volume ls

# Reconstruir a imagem após alterações
docker compose up -d --build

# Acessar o banco via psql (dentro do container)
docker exec -it iot_db psql -U postgres -d iot_monitor
```

---

## 🌐 Portas Utilizadas

| Serviço     | Porta interna | Porta externa |
|-------------|---------------|---------------|
| Aplicação   | 3000          | 3000          |
| PostgreSQL  | 5432          | não exposta   |

> O banco de dados **não é exposto** externamente por segurança. Apenas a aplicação acessa o banco pela rede interna Docker.

---

## ⚙️ Variáveis de Ambiente

| Variável       | Padrão       | Descrição                     |
|----------------|--------------|-------------------------------|
| `DB_NAME`      | iot_monitor  | Nome do banco de dados        |
| `DB_USER`      | postgres     | Usuário do PostgreSQL         |
| `DB_PASSWORD`  | postgres     | Senha do PostgreSQL           |
| `APP_PORT`     | 3000         | Porta externa da aplicação    |

---

## 🐳 Docker Compose — Detalhes

O arquivo `docker-compose.yml` define:

- **Serviço `db`**: PostgreSQL 15-alpine com healthcheck
- **Serviço `app`**: Node.js construído a partir do Dockerfile local
- **Volume `iot_pgdata`**: garante que os dados sobrevivam ao reinício
- **Rede `iot_network`**: comunicação interna entre app e banco
- **`depends_on` com `condition: service_healthy`**: a aplicação só sobe após o banco estar pronto

---

## 🔗 DockerHub

A imagem da aplicação está publicada em:

```
docker pull SEU_USUARIO/iot-monitor:latest
```

---

## 📁 Estrutura do Projeto

```
projeto/
├── app/
│   ├── src/
│   │   ├── server.js          # API REST + servidor Express
│   │   └── public/
│   │       └── index.html     # Interface web (frontend)
│   ├── package.json
│   └── Dockerfile
├── evidencias/                # Prints obrigatórios
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## 📡 Endpoints da API

| Método | Rota                        | Descrição                  |
|--------|-----------------------------|----------------------------|
| GET    | /api/sensors                | Lista todos os sensores    |
| GET    | /api/sensors/:id            | Busca sensor por ID        |
| POST   | /api/sensors                | Cadastra novo sensor       |
| PUT    | /api/sensors/:id            | Atualiza sensor            |
| DELETE | /api/sensors/:id            | Remove sensor              |
| GET    | /api/readings               | Lista todas as leituras    |
| GET    | /api/sensors/:id/readings   | Leituras de um sensor      |
| POST   | /api/readings               | Registra nova leitura      |
| PUT    | /api/readings/:id           | Atualiza status de leitura |
| DELETE | /api/readings/:id           | Remove leitura             |
| GET    | /health                     | Verificação de saúde       |
