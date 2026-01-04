const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));




// Conectar ao MongoDB Atlas
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Conectado ao MongoDB Atlas');
  } catch (error) {
    console.error('❌ Erro ao conectar ao MongoDB:', error.message);
    process.exit(1);
  }
};

connectDB();

// Rotas

app.use('/api/eventos', require('./routes/eventos'));
app.use('/api/instituicoes', require('./routes/instituicoes'));
app.use('/api/subeventos', require('./routes/subeventos'));



// Rota de saúde
app.get('/api/health', (req, res) => {
  res.json({ status: 'API está funcionando!' });
});

// Rota raiz
app.get('/', (req, res) => {
  res.json({ mensagem: 'Bem-vindo à API APEC' });
});

// Middleware de erro para rotas não encontradas
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});


// Iniciar servidor (escuta em todas as interfaces para permitir acesso de dispositivos na mesma rede)
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📍 Acesse (da máquina): http://localhost:${PORT}`);
  console.log(`📡 Acesse (na mesma rede): http://<IP_DA_SUA_MAQUINA>:${PORT}`);
});