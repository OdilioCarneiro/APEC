const Evento = require('../models/Evento');
const SubEvento = require('../models/Subevento');

// Listar todos os eventos (já trazendo instituição)
exports.listarEventos = async (req, res) => {
  try {
    const eventos = await Evento.find()
      .populate('instituicaoId', 'nome fotoUrl')
      .sort({ data: 1 });

    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar eventos', detalhes: error.message });
  }
};

// Obter evento por ID
exports.obterEvento = async (req, res) => {
  try {
    const evento = await Evento.findById(req.params.id)
      .populate('instituicaoId', 'nome fotoUrl');

    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });
    return res.json(evento);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao obter evento', detalhes: error.message });
  }
};

// Criar evento (imagem opcional)
exports.criarEvento = async (req, res) => {
  try {
    const dados = { ...req.body };

    if (!dados.nome || !dados.categoria || !dados.data || !dados.horario || !dados.local) {
      return res.status(400).json({ erro: 'Campos obrigatórios faltando' });
    }
    if (!dados.instituicaoId) {
      return res.status(400).json({ erro: 'instituicaoId é obrigatório' });
    }

    if (req.file) dados.imagem = req.file.path;

    const novoEvento = new Evento(dados);
    await novoEvento.save();

    const eventoPopulado = await Evento.findById(novoEvento._id)
      .populate('instituicaoId', 'nome fotoUrl');

    return res.status(201).json(eventoPopulado);
  } catch (error) {
    return res.status(400).json({ erro: 'Erro ao criar evento', detalhes: error.message });
  }
};

exports.atualizarEvento = async (req, res) => {
  try {
    const evento = await Evento.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate('instituicaoId', 'nome fotoUrl');

    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });
    return res.json(evento);
  } catch (error) {
    return res.status(400).json({ erro: 'Erro ao atualizar evento', detalhes: error.message });
  }
};

exports.deletarEvento = async (req, res) => {
  try {
    const evento = await Evento.findByIdAndDelete(req.params.id);
    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });
    return res.json({ mensagem: 'Evento deletado com sucesso' });
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao deletar evento', detalhes: error.message });
  }
};

exports.listarEventosPorCategoria = async (req, res) => {
  try {
    const { categoria } = req.params;
    const eventos = await Evento.find({ categoria })
      .populate('instituicaoId', 'nome fotoUrl')
      .sort({ data: 1 });

    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar eventos por categoria', detalhes: error.message });
  }
};

exports.listarEventosPorInstituicao = async (req, res) => {
  try {
    const { instituicaoId } = req.params;

    const eventos = await Evento.find({ instituicaoId })
      .populate('instituicaoId', 'nome fotoUrl')
      .sort({ data: 1 });

    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar eventos da instituição', detalhes: error.message });
  }
};

// RENOMEAR categoria (atualiza evento + subeventos)
exports.renomearCategoriaSubeventos = async (req, res) => {
  try {
    const { antiga, nova } = req.body;
    if (!antiga || !nova) return res.status(400).json({ erro: 'antiga e nova são obrigatórios' });

    const antigaTrim = String(antiga).trim();
    const novaTrim = String(nova).trim();
    if (!antigaTrim || !novaTrim) return res.status(400).json({ erro: 'antiga/nova inválidas' });

    // 1) Atualiza categoriasSubeventos no evento
    const evento = await Evento.findById(req.params.id);
    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });

    const cats = Array.isArray(evento.categoriasSubeventos) ? evento.categoriasSubeventos : [];
    evento.categoriasSubeventos = cats.map((c) => (String(c).trim() === antigaTrim ? novaTrim : c));
    await evento.save();

    // 2) Atualiza todos os subeventos daquela categoria
    await SubEvento.updateMany(
      { eventoPaiId: req.params.id, categoria: antigaTrim },
      { $set: { categoria: novaTrim } }
    );

    // 3) Retorna evento atualizado
    const eventoPop = await Evento.findById(req.params.id)
      .populate('instituicaoId', 'nome fotoUrl');

    return res.json(eventoPop);
  } catch (error) {
    return res.status(400).json({ erro: 'Erro ao renomear categoria', detalhes: error.message });
  }
};
