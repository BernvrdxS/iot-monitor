// app.js
// ==========================================================================
// IoT Monitor API
// API REST para consulta do status da aplicação e dos sensores IoT
// monitorados. Disciplina: Cloud Computing - UNIDAVI.
// ==========================================================================

const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();

// Caminho do arquivo de dados simulados. Os dados ficam em um JSON externo
// (não "hardcoded" como string no código) para que possam ser atualizados
// sem alterar a lógica da API - simula como uma camada de persistência real
// (ex.: banco de dados) se comportaria.
const CAMINHO_DADOS = path.join(__dirname, 'data', 'sensores.json');

/**
 * Lê e retorna a lista de sensores a partir do arquivo JSON.
 * Lança erro caso o arquivo não exista ou esteja corrompido, permitindo que
 * as rotas tratem essa falha retornando HTTP 500 (erro interno).
 */
function carregarSensores() {
  const conteudo = fs.readFileSync(CAMINHO_DADOS, 'utf-8');
  return JSON.parse(conteudo);
}

// --------------------------------------------------------------------------
// GET /status
// Rota de "health check" da aplicação: informa nome, versão e status atual.
// Útil em ambientes de nuvem para checagens automáticas de disponibilidade
// (ex.: load balancers, orquestradores de containers, monitoramento).
// --------------------------------------------------------------------------
app.get('/status', (req, res) => {
  res.status(200).json({
    sucesso: true,
    dados: {
      nome: 'IoT Monitor API',
      versao: '1.0.0',
      status: 'online',
    },
  });
});

// --------------------------------------------------------------------------
// GET /sensores
// Retorna a lista completa de sensores simulados cadastrados no sistema.
// --------------------------------------------------------------------------
app.get('/sensores', (req, res) => {
  try {
    const sensores = carregarSensores();
    res.status(200).json({
      sucesso: true,
      total: sensores.length,
      dados: sensores,
    });
  } catch (erro) {
    res.status(500).json({
      sucesso: false,
      erro: 'Erro interno ao carregar os dados dos sensores.',
    });
  }
});

// --------------------------------------------------------------------------
// GET /sensores/:id
// Retorna um único sensor pelo identificador. Retorna 404 quando o
// identificador informado não corresponde a nenhum sensor cadastrado.
// --------------------------------------------------------------------------
app.get('/sensores/:id', (req, res) => {
  try {
    const sensores = carregarSensores();
    const id = Number(req.params.id);
    const sensor = sensores.find((s) => s.id === id);

    if (!sensor) {
      return res.status(404).json({
        sucesso: false,
        erro: `Sensor com id ${req.params.id} não foi encontrado.`,
      });
    }

    return res.status(200).json({
      sucesso: true,
      dados: sensor,
    });
  } catch (erro) {
    return res.status(500).json({
      sucesso: false,
      erro: 'Erro interno ao carregar os dados do sensor.',
    });
  }
});

// Qualquer rota não mapeada cai aqui -> 404 padronizado.
app.use((req, res) => {
  res.status(404).json({
    sucesso: false,
    erro: 'Rota não encontrada.',
  });
});

module.exports = app;
