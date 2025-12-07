const Evento = require('../models/Evento');

// Listar todos os eventos
exports.listarEventos = async (req, res) => {
  try {
    const eventos = await Evento.find().sort({ data: 1 });
    res.json(eventos);
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao listar eventos', detalhes: error.message });
  }
};

// Obter evento por ID
exports.obterEvento = async (req, res) => {
  try {
    const evento = await Evento.findById(req.params.id);
    if (!evento) {
      return res.status(404).json({ erro: 'Evento não encontrado' });
    }
    res.json(evento);
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao obter evento', detalhes: error.message });
  }
};

// Criar novo evento (adaptado para usar Cloudinary)
exports.criarEvento = async (req, res) => {
  try {
    console.log('BODY:', req.body);
    console.log('FILE:', req.file);

    const dados = req.body;

    if (req.file) {
      dados.imagem = "imagem_recebida_ok"; // depois troca pelo Cloudinary
    }

    const novoEvento = new Evento(dados);
    await novoEvento.save();

    res.status(201).json(novoEvento);
  } catch (error) {
    res.status(400).json({
      erro: 'Erro ao criar evento',
      detalhes: error.message
    });
  }
};


// Atualizar evento
exports.atualizarEvento = async (req, res) => {
  try {
    const evento = await Evento.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!evento) {
      return res.status(404).json({ erro: 'Evento não encontrado' });
    }
    res.json(evento);
  } catch (error) {
    res.status(400).json({ erro: 'Erro ao atualizar evento', detalhes: error.message });
  }
};

// Deletar evento
exports.deletarEvento = async (req, res) => {
  try {
    const evento = await Evento.findByIdAndDelete(req.params.id);
    if (!evento) {
      return res.status(404).json({ erro: 'Evento não encontrado' });
    }
    res.json({ mensagem: 'Evento deletado com sucesso' });
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao deletar evento', detalhes: error.message });
  }
};

// Listar eventos por categoria
exports.listarEventosPorCategoria = async (req, res) => {
  try {
    const { categoria } = req.params;
    const eventos = await Evento.find({ categoria }).sort({ data: 1 });
    res.json(eventos);
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao listar eventos por categoria', detalhes: error.message });
  }
};
