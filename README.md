# IoT Monitor — Trabalho Final de Cloud Computing

**Disciplina:** Cloud Computing — UNIDAVI
**Tema individual:** Monitoramento de Sensores IoT
**Projeto:** API REST com pipeline de Integração Contínua (GitHub Actions)

## Sobre o projeto

A **IoT Monitor API** expõe informações de sensores IoT simulados
(temperatura, umidade, pressão, luminosidade, movimento, gases, nível de
água, ruído, qualidade do ar, vibração, fluxo de água e corrente elétrica),
permitindo consultar o status da aplicação e os dados coletados por cada
sensor.

---

## Tecnologias utilizadas

| Tecnologia       | Finalidade                                   |
|------------------|-----------------------------------------------|
| Node.js          | Runtime da API                                |
| Express          | Framework HTTP / definição das rotas REST     |
| Jest             | Execução dos testes unitários                 |
| Supertest        | Simulação de requisições HTTP nos testes      |
| ESLint           | Análise estática de código (lint)             |
| Docker           | Containerização da API                        |
| GitHub Actions   | Pipeline de Integração Contínua (CI)          |

---

## Estrutura do projeto

```
iot-monitor/
├── api/
│   ├── app.js               # Definição do app Express e das rotas
│   ├── server.js            # Inicialização do servidor HTTP
│   ├── data/
│   │   └── sensores.json    # Dados simulados (12 sensores)
│   ├── tests/
│   │   └── sensores.test.js # Testes unitários (Jest + Supertest)
│   ├── Dockerfile           # Imagem da API
│   ├── package.json
│   └── .eslintrc.json
├── .github/
│   └── workflows/
│       └── ci.yml           # Pipeline de Integração Contínua
└── README.md
```

---

## Endpoints disponíveis

| Método | Rota              | Descrição                                                      |
|--------|-------------------|----------------------------------------------------------------|
| GET    | `/status`         | Health check: nome, versão e status da aplicação               |
| GET    | `/sensores`       | Lista todos os sensores simulados                              |
| GET    | `/sensores/{id}`  | Retorna um sensor específico pelo `id` (404 se não existir)    |

### Exemplo de resposta — `GET /status`
```json
{
  "sucesso": true,
  "dados": { "nome": "IoT Monitor API", "versao": "1.0.0", "status": "online" }
}
```

### Exemplo de resposta — `GET /sensores/3`
```json
{
  "sucesso": true,
  "dados": {
    "id": 3,
    "nome": "Sensor de Pressão Atmosférica - Cobertura",
    "tipo": "pressao_atmosferica",
    "localizacao": "Cobertura - Telhado Técnico",
    "unidadeMedida": "hPa",
    "ultimaLeitura": 1013.2,
    "status": "ativo",
    "bateria": 76,
    "dataInstalacao": "2025-03-01"
  }
}
```

### Exemplo de resposta — `GET /sensores/999` (inexistente)
```json
{ "sucesso": false, "erro": "Sensor com id 999 não foi encontrado." }
```
HTTP Status: `404`

---

## Como executar — SEM container (local)

### Pré-requisitos
- [Node.js 20+](https://nodejs.org/) instalado
- npm (já incluso no Node.js)

### Passo a passo
```bash
git clone https://github.com/BernvrdxS/iot-monitor.git
cd iot-monitor/api

# instalar dependências
npm install

# iniciar a API
npm start
```
A API ficará disponível em `http://localhost:3000`.

### Executar os testes unitários
```bash
cd iot-monitor/api
npm test
```

### Executar o lint
```bash
cd iot-monitor/api
npm run lint
```

---

## Como executar — COM container (Docker)

### Pré-requisitos
- [Docker](https://docs.docker.com/get-docker/) instalado e em execução

### Passo a passo
```bash
cd iot-monitor/api

# construir a imagem
docker build -t iot-monitor-api .

# executar o container, expondo a porta 3000
docker run -p 3000:3000 iot-monitor-api
```
A API ficará disponível em `http://localhost:3000`.

---

## Pipeline de Integração Contínua (CI)

A cada `push` ou `pull request` para a branch `main`, o GitHub Actions executa automaticamente (`.github/workflows/ci.yml`):

1. Checkout do código
2. Configuração do Node.js 20
3. Instalação das dependências (`npm ci`)
4. Lint do código (ESLint)
5. Execução dos testes unitários (Jest, com cobertura)
6. Publicação do relatório de cobertura como artefato do workflow

O status de cada execução pode ser visto na aba **Actions** do repositório no GitHub.