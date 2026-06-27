// tests/sensores.test.js
// Testes unitários da IoT Monitor API.
// Usa Jest como executor/asserções e Supertest para simular requisições
// HTTP contra o app Express, sem precisar de um servidor real rodando.

const request = require('supertest');
const app = require('../app');

describe('GET /status', () => {
  test('deve retornar 200 e as informações da aplicação', async () => {
    const resposta = await request(app).get('/status');
    expect(resposta.statusCode).toBe(200);
    expect(resposta.body.dados).toHaveProperty('nome');
    expect(resposta.body.dados).toHaveProperty('versao');
    expect(resposta.body.dados).toHaveProperty('status');
  });
});

describe('GET /sensores', () => {
  // Teste obrigatório 1: retorno HTTP 200 para a rota GET /[recurso]
  test('deve retornar status HTTP 200', async () => {
    const resposta = await request(app).get('/sensores');
    expect(resposta.statusCode).toBe(200);
  });

  // Teste obrigatório 2: validação da estrutura do JSON retornado
  test('deve retornar uma lista de sensores com os campos obrigatórios', async () => {
    const resposta = await request(app).get('/sensores');

    expect(resposta.body.sucesso).toBe(true);
    expect(Array.isArray(resposta.body.dados)).toBe(true);
    expect(resposta.body.dados.length).toBeGreaterThanOrEqual(10);

    resposta.body.dados.forEach((sensor) => {
      expect(sensor).toHaveProperty('id');
      expect(sensor).toHaveProperty('nome');
      expect(sensor).toHaveProperty('tipo');
      expect(sensor).toHaveProperty('localizacao');
      expect(sensor).toHaveProperty('unidadeMedida');
      expect(sensor).toHaveProperty('ultimaLeitura');
      expect(sensor).toHaveProperty('status');
    });
  });
});

describe('GET /sensores/:id', () => {
  // Teste obrigatório 3: retorno HTTP 404 para id inexistente
  test('deve retornar 404 para um id inexistente', async () => {
    const resposta = await request(app).get('/sensores/9999');
    expect(resposta.statusCode).toBe(404);
    expect(resposta.body.sucesso).toBe(false);
  });

  // Teste obrigatório 4 (autoria própria): valida uma REGRA DE NEGÓCIO dos
  // dados, e não apenas o contrato HTTP. O campo "bateria" é usado para
  // decidir se um sensor precisa de manutenção (ex.: alertar quando < 20%).
  // Esse teste garante que esse campo nunca fique fora da faixa percentual
  // válida (0 a 100), o que protegeria o sistema contra dados simulados
  // (ou futuramente vindos de hardware real) inconsistentes que poderiam
  // gerar alertas de manutenção incorretos.
  test('[Teste próprio] todo sensor deve ter o campo bateria entre 0 e 100', async () => {
    const resposta = await request(app).get('/sensores');
    resposta.body.dados.forEach((sensor) => {
      expect(sensor.bateria).toBeGreaterThanOrEqual(0);
      expect(sensor.bateria).toBeLessThanOrEqual(100);
    });
  });
});
