const mongoose = require('mongoose');
const Evento = require('../models/Evento');
const SubEvento = require('../models/Subevento');
 // ou '../models/Subevento' conforme o nome real do arquivo


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
// controllers/eventoController.js

exports.renomearCategoriaSubeventos = async (req, res) => {
  try {
    const { id } = req.params;
    let { antiga, nova } = req.body;

    console.log('RENAME REQUEST (ATOMIC):', { id, antiga, nova });

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    antiga = (antiga || '').toString().trim();
    nova = (nova || '').toString().trim();

    if (!antiga || !nova) {
      return res.status(400).json({ message: 'Antiga e nova são obrigatórias' });
    }

    // 1. Busca o evento atual
    const eventoOriginal = await Evento.findById(id);
    if (!eventoOriginal) {
      return res.status(404).json({ message: 'Evento não encontrado' });
    }

    // Calcula novo array de categorias
    const catsAntigas = (eventoOriginal.categoriasSubeventos || [])
        .map(c => (c || '').trim());

    const catsNovas = catsAntigas.map(c =>
      c.toLowerCase() === antiga.toLowerCase() ? nova : c
    );

    // Remove duplicatas e garante "Subeventos"
    const unique = ['Subeventos'];
    const seen = new Set(['subeventos']);
    for (const c of catsNovas) {
      if (!c) continue;
      const k = c.toLowerCase();
      if (!seen.has(k)) {
        seen.add(k);
        unique.push(c);
      }
    }

    // 2. Atualiza o evento ATOMICAMENTE (sem .save(), evitando VersionError)
    const eventoAtualizado = await Evento.findOneAndUpdate(
      { _id: id },
      { $set: { categoriasSubeventos: unique } },
      { new: true }
    ).populate('instituicaoId', 'nome fotoUrl');

    // 3. Migra subeventos daquela categoria
    const resultSubs = await SubEvento.updateMany(
      { eventoPaiId: id, categoria: antiga },
      { $set: { categoria: nova } }
    );
    console.log('Subeventos migrados:', resultSubs);

    return res.json(eventoAtualizado);

  } catch (err) {
    console.error('ERRO RENAME:', err);
    return res.status(500).json({
      message: 'Erro ao renomear categoria',
      error: err.message
    });
  }
};



