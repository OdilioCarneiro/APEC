// apec-backend/controllers/subeventosController.js
const SubEvento = require('../models/Subevento');



exports.listarSubEventos = async (req, res) => {
  try {
    const filtro = {};
    if (req.query.eventoPaiId) filtro.eventoPaiId = req.query.eventoPaiId;

    const subeventos = await SubEvento.find(filtro)
      .populate('instituicaoId', 'nome fotoUrl')
      .populate('eventoPaiId', 'nome data horario local')
      .sort({ data: 1 });

    return res.json(subeventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar subeventos', detalhes: error.message });
  }
};

exports.obterSubEvento = async (req, res) => {
  try {
    const subevento = await SubEvento.findById(req.params.id)
      .populate('instituicaoId', 'nome fotoUrl')
      .populate('eventoPaiId', 'nome data horario local');

    if (!subevento) return res.status(404).json({ erro: 'SubEvento não encontrado' });
    return res.json(subevento);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao obter subevento', detalhes: error.message });
  }
};

exports.criarSubEvento = async (req, res) => {
  try {
    const dados = { ...req.body };

    if (!dados.nome || !dados.data || !dados.horario || !dados.local) {
      return res.status(400).json({ erro: 'Campos obrigatórios faltando' });
    }
    if (!dados.instituicaoId) {
      return res.status(400).json({ erro: 'instituicaoId é obrigatório' });
    }
    if (!dados.eventoPaiId) {
      return res.status(400).json({ erro: 'eventoPaiId é obrigatório' });
    }

    // Categoria: texto da row (padrão Subeventos)
    dados.categoria = (dados.categoria || 'Subeventos').toString().trim();
    if (!dados.categoria) dados.categoria = 'Subeventos';

    if (req.file) {
      dados.imagem = req.file.path;
    }

    const novo = new SubEvento(dados);
    await novo.save();

    const populado = await SubEvento.findById(novo._id)
      .populate('instituicaoId', 'nome fotoUrl')
      .populate('eventoPaiId', 'nome data horario local');

    return res.status(201).json(populado);
  } catch (error) {
    console.error('Erro ao criar subevento:', error);
    return res
      .status(400)
      .json({ erro: 'Erro ao criar subevento', detalhes: error.message });
  }
};




exports.atualizarSubEvento = async (req, res) => {
  try {
    const atualizado = await SubEvento.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    })
      .populate('instituicaoId', 'nome fotoUrl')
      .populate('eventoPaiId', 'nome data horario local');

    if (!atualizado) return res.status(404).json({ erro: 'SubEvento não encontrado' });
    return res.json(atualizado);
  } catch (error) {
    return res.status(400).json({ erro: 'Erro ao atualizar subevento', detalhes: error.message });
  }
};

exports.deletarSubEvento = async (req, res) => {
  try {
    const subevento = await SubEvento.findByIdAndDelete(req.params.id);
    if (!subevento) return res.status(404).json({ erro: 'SubEvento não encontrado' });
    return res.json({ mensagem: 'SubEvento deletado com sucesso' });
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao deletar subevento', detalhes: error.message });
  }
};
