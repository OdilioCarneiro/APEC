const router = require('express').Router();
const mongoose = require('mongoose');

// Importar os Models
const Instituicao = require('../models/Instituicao');
const Evento = require('../models/Evento');
const Subevento = require('../models/Subevento');

// Função auxiliar para escapar caracteres especiais do Regex
function escapeRegex(text) {
  return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
}

// Função que transforma "apresentacao" em um Regex que aceita "Apresentação"
function criarRegexInteligente(texto) {
  const termo = texto.split('').map(char => {
      // Se for A, aceita todos os tipos de A
      if (/[aáàâã]/i.test(char)) return '[aáàâãAÁÀÂÃ]';
      // Se for E, aceita todos os tipos de E
      if (/[eéèê]/i.test(char)) return '[eéèêEÉÈÊ]';
      // Se for I, aceita todos os tipos de I
      if (/[iíìî]/i.test(char)) return '[iíìîIÍÌÎ]';
      // Se for O, aceita todos os tipos de O
      if (/[oóòôõ]/i.test(char)) return '[oóòôõOÓÒÔÕ]';
      // Se for U, aceita todos os tipos de U
      if (/[uúùû]/i.test(char)) return '[uúùûUÚÙÛ]';
      // Se for C ou Ç, aceita os dois
      if (/[cç]/i.test(char)) return '[cçCÇ]';
      
      return escapeRegex(char);
  }).join('');
  
  return new RegExp(termo, 'i'); // 'i' ignora maiúsculas/minúsculas
}

// Rota GET /api/search?q=termo
router.get('/', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.json({ instituicoes: [], eventos: [], subeventos: [] });
    }

    // Cria o regex poderoso
    const regex = criarRegexInteligente(q);
    console.log(`Buscando por: ${q} | Regex gerado: ${regex}`);

    const [instituicoes, eventos, subeventos] = await Promise.all([
      Instituicao.find({ 
        $or: [
          { nome: regex }, 
          { sigla: regex },
          { campus: regex },
          { email: regex }
        ] 
      }),

      Evento.find({ 
        $or: [
          { nome: regex }, 
          { titulo: regex }, 
          { descricao: regex },
          { local: regex },
          { categoria: regex }
        ] 
      }).populate('instituicaoId', 'nome imagem'),

      Subevento.find({ 
        $or: [
          { nome: regex },
          { titulo: regex }, 
          { descricao: regex },
          { tema: regex }
        ] 
      }).populate('eventoId', 'nome')
    ]);

    return res.json({
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
