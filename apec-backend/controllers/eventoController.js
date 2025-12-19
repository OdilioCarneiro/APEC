const Evento = require('../models/Evento');

// Listar todos os eventos
exports.listarEventos = async (req, res) => {
  try {
    const eventos = await Evento.find().sort({ data: 1 });
    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({
      erro: 'Erro ao listar eventos',
      detalhes: error.message,
    });
  }
};

// Obter evento por ID
exports.obterEvento = async (req, res) => {
  try {
    const evento = await Evento.findById(req.params.id);
    if (!evento) {
      return res.status(404).json({ erro: 'Evento não encontrado' });
    }
    return res.json(evento);
  } catch (error) {
    return res.status(500).json({
      erro: 'Erro ao obter evento',
      detalhes: error.message,
    });
  }
};

// Criar novo evento (com imagem opcional / Cloudinary)
exports.criarEvento = async (req, res) => {
  try {
    // Se vier multipart, req.body vem como strings
    const dados = { ...req.body };

    // validação mínima (ajuste se quiser)
    if (!dados.nome || !dados.categoria || !dados.data || !dados.horario || !dados.local) {
      return res.status(400).json({ erro: 'Campos obrigatórios faltando' });
    }

    // obrigatório para aparecer nos eventos da instituição
    if (!dados.instituicaoId) {
      return res.status(400).json({ erro: 'instituicaoId é obrigatório' });
    }

    // se veio imagem (multer + cloudinary), salva a URL
    if (req.file) {
      dados.imagem = req.file.path;
    }

    const novoEvento = new Evento(dados);
    await novoEvento.save();

    return res.status(201).json(novoEvento);
  } catch (error) {
    return res.status(400).json({
      erro: 'Erro ao criar evento',
      detalhes: error.message,
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

    return res.json(evento);
  } catch (error) {
    return res.status(400).json({
      erro: 'Erro ao atualizar evento',
      detalhes: error.message,
    });
  }
};

// Deletar evento
exports.deletarEvento = async (req, res) => {
  try {
    const evento = await Evento.findByIdAndDelete(req.params.id);

    if (!evento) {
      return res.status(404).json({ erro: 'Evento não encontrado' });
    }

    return res.json({ mensagem: 'Evento deletado com sucesso' });
  } catch (error) {
    return res.status(500).json({
      erro: 'Erro ao deletar evento',
      detalhes: error.message,
    });
  }
};

// Listar eventos por categoria
exports.listarEventosPorCategoria = async (req, res) => {
  try {
    const { categoria } = req.params;
    const eventos = await Evento.find({ categoria }).sort({ data: 1 });
    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({
      erro: 'Erro ao listar eventos por categoria',
      detalhes: error.message,
    });
  }
};

// Listar eventos por instituição
exports.listarEventosPorInstituicao = async (req, res) => {
  try {
    const { instituicaoId } = req.params;
    const eventos = await Evento.find({ instituicaoId }).sort({ data: 1 });
    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({
      erro: 'Erro ao listar eventos da instituição',
      detalhes: error.message,
    });
  }
};
