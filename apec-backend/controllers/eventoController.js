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
exports.renomearCategoriaSubeventos = async (req, res) => {
  try {
    const { id } = req.params;
    let { antiga, nova } = req.body;

    console.log('RENAME REQUEST:', { id, antiga, nova });

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID de evento inválido' });
    }

    antiga = (antiga || '').toString().trim();
    nova = (nova || '').toString().trim();

    if (!antiga || !nova) {
      return res
        .status(400)
        .json({ message: 'Categoria antiga e nova são obrigatórias' });
    }

    const evento = await Evento.findById(id);
    if (!evento) {
      return res.status(404).json({ message: 'Evento não encontrado' });
    }

    // 1) Atualiza array de categorias do evento (case-insensitive)
    const cats = (evento.categoriasSubeventos || []).map((c) =>
      (c || '').toString().trim()
    );
    evento.categoriasSubeventos = cats.map((c) =>
      c.toLowerCase() === antiga.toLowerCase() ? nova : c
    );

    // Garante "Subeventos" e remove duplicadas
    const seen = new Set(['subeventos']);
    const unique = ['Subeventos'];
    for (const c of evento.categoriasSubeventos) {
      if (!c) continue;
      const lower = c.toLowerCase();
      if (!seen.has(lower)) {
        seen.add(lower);
        unique.push(c);
      }
    }
    evento.categoriasSubeventos = unique;

    await evento.save();
    console.log('Evento atualizado, categorias:', evento.categoriasSubeventos);

    // 2) Atualiza todos os subeventos daquela categoria
    const result = await SubEvento.updateMany(
      { eventoPaiId: id, categoria: antiga },
      { $set: { categoria: nova } }
    );
    console.log('Subeventos migrados:', result);

    const eventoPop = await Evento.findById(id).populate(
      'instituicaoId',
      'nome fotoUrl'
    );
    return res.json(eventoPop);
  } catch (err) {
    console.error('ERRO CRÍTICO NO RENAME:', err);
    return res.status(500).json({
      message: 'Erro ao renomear categoria',
      error: err.message || String(err),
    });
  }
};



