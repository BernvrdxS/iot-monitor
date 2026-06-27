// server.js
// Ponto de entrada que inicializa o servidor HTTP.
// Mantido separado do app.js para que os testes possam importar somente o
// app Express (sem abrir uma porta de rede real), usando supertest.

const app = require('./app');

const PORTA = process.env.PORT || 3000;

app.listen(PORTA, () => {
  console.log(`IoT Monitor API rodando na porta ${PORTA}`);
});
