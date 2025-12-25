const mongoose = require('mongoose');
const Evento = require('../models/Evento');

const SubEvento = require('../models/Subevento');

exports.listarEventos = async (req, res) => {
  try {
    const eventos = await Evento.find()
      .populate('instituicaoId', 'nome imagem')
      .sort({ data: 1 });

    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar eventos', detalhes: error.message });
  }
};

exports.obterEvento = async (req, res) => {
  try {
    const evento = await Evento.findById(req.params.id)
      .populate('instituicaoId', 'nome imagem');

    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });
    return res.json(evento);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao obter evento', detalhes: error.message });
  }
};

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
      .populate('instituicaoId', 'nome imagem');

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
    }).populate('instituicaoId', 'nome imagem');

    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });
    return res.json(evento);
  } catch (error) {
    return res.status(400).json({ erro: 'Erro ao atualizar evento', detalhes: error.message });
  }
};

exports.deletarEvento = async (req, res) => {
  try {
    const eventoId = req.params.id;

    // apaga subeventos do evento antes
    await SubEvento.deleteMany({ eventoPaiId: eventoId });

    const evento = await Evento.findByIdAndDelete(eventoId);
    if (!evento) return res.status(404).json({ erro: 'Evento não encontrado' });

    return res.status(204).send();
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao deletar evento', detalhes: error.message });
  }
};

exports.listarEventosPorCategoria = async (req, res) => {
  try {
    const { categoria } = req.params;

    const eventos = await Evento.find({ categoria })
      .populate('instituicaoId', 'nome imagem')
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
      .populate('instituicaoId', 'nome imagem')
      .sort({ data: 1 });

    return res.json(eventos);
  } catch (error) {
    return res.status(500).json({ erro: 'Erro ao listar eventos da instituição', detalhes: error.message });
  }
};

exports.renomearCategoriaSubeventos = async (req, res) => {
  try {
    const { id } = req.params;
    let { antiga, nova } = req.body || {};

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    antiga = (antiga || '').toString().trim();
    nova = (nova || '').toString().trim();

    if (!antiga || !nova) {
      return res.status(400).json({ message: 'Antiga e nova são obrigatórias' });
    }

    const eventoOriginal = await Evento.findById(id);
    if (!eventoOriginal) {
      return res.status(404).json({ message: 'Evento não encontrado' });
    }

    const catsAntigas = (eventoOriginal.categoriasSubeventos || [])
      .map((c) => (c || '').toString().trim())
      .filter((c) => c.length > 0);

    const catsRenomeadas = catsAntigas.map((c) =>
      c.toLowerCase() === antiga.toLowerCase() ? nova : c
    );

    // Remove duplicatas (case-insensitive) e garante pelo menos 1
    const seen = new Set();
    const unique = [];
    for (const c of catsRenomeadas) {
      if (!c) continue;
      const k = c.toLowerCase();
      if (!seen.has(k)) {
        seen.add(k);
        unique.push(c);
      }
    }
    if (unique.length === 0) unique.push('Nova categoria');

    const eventoAtualizado = await Evento.findOneAndUpdate(
      { _id: id },
      { $set: { categoriasSubeventos: unique } },
      { new: true }
    ).populate('instituicaoId', 'nome imagem');

    await SubEvento.updateMany(
      { eventoPaiId: id, categoria: antiga },
      { $set: { categoria: nova } }
    );

    return res.json(eventoAtualizado);
  } catch (err) {
    return res.status(500).json({
      message: 'Erro ao renomear categoria',
      error: err.message,
    });
  }
};
