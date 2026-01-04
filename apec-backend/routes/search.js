const router = require('express').Router();
const mongoose = require('mongoose');

// Importando os Models
const Instituicao = require('../models/Instituicao');
const Evento = require('../models/Evento');
const Subevento = require('../models/Subevento');

// Rota GET /api/search?q=termo
router.get('/', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(200).json({ instituicoes: [], eventos: [], subeventos: [] });
    }

    // Executa as 3 buscas ao mesmo tempo usando os índices de texto criados
    const [instituicoes, eventos, subeventos] = await Promise.all([
      Instituicao.find({ $text: { $search: q } }),
      Evento.find({ $text: { $search: q } }).populate('instituicaoId', 'nome imagem'),
      Subevento.find({ $text: { $search: q } }).populate('eventoId', 'nome')
    ]);

    return res.status(200).json({
      instituicoes,
      eventos,
      subeventos
    });

  } catch (error) {
    console.error('Erro na pesquisa:', error);
    return res.status(500).json({ error: 'Erro interno na busca' });
  }
});

module.exports = router;
