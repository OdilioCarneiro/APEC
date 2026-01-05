const router = require('express').Router();
const mongoose = require('mongoose');

// Importar os Models
const Instituicao = require('../models/Instituicao');
const Evento = require('../models/Evento');
const Subevento = require('../models/Subevento');

// === FUNÇÕES DE AJUDA ===
function removerAcentos(str) {
  if (!str) return "";
  return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

function criarRegexBlindado(textoUsuario) {
  const limpo = removerAcentos(textoUsuario);
  const padrao = limpo.split('').map(char => {
    if (/[aA]/.test(char)) return '[aáàâãäAÁÀÂÃÄ]';
    if (/[eE]/.test(char)) return '[eéèêëEÉÈÊË]';
    if (/[iI]/.test(char)) return '[iíìîïIÍÌÎÏ]';
    if (/[oO]/.test(char)) return '[oóòôõöOÓÒÔÕÖ]';
    if (/[uU]/.test(char)) return '[uúùûüUÚÙÛÜ]';
    if (/[cC]/.test(char)) return '[cçCÇ]';
    if (/\s/.test(char)) return '\\s+'; // Espaço flexível
    return char.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
  }).join('');
  return new RegExp(padrao, 'i');
}

// === ROTA ===
router.get('/', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.json({ instituicoes: [], eventos: [], subeventos: [] });

    const regex = criarRegexBlindado(q);
    console.log(`Buscando por: ${q} | Regex: ${regex}`);

    const [instituicoes, eventos, subeventos] = await Promise.all([
      // Instituição
      Instituicao.find({
        $or: [
          { nome: regex },
          { sigla: regex },
          { campus: regex },
          { email: regex }
        ]
      }),

      // Evento - ADICIONADO: categoriaCultural, categoriaEsportiva, artistas, tema
      Evento.find({
        $or: [
          { nome: regex },
          { titulo: regex },
          { descricao: regex },
          { local: regex },
          { categoria: regex },
          { categoriaCultural: regex }, // <--- Importante
          { categoriaEsportiva: regex }, // <--- Importante
          { artistas: regex },
          { tema: regex }
        ]
      }).populate('instituicaoId', 'nome imagem'),

      // Subevento - ADICIONADO: palestrante
      Subevento.find({
        $or: [
          { nome: regex },
          { titulo: regex },
          { descricao: regex },
          { tema: regex },
          { palestrante: regex } // <--- Importante
        ]
      }).populate('eventoId', 'nome')
    ]);

    return res.json({ instituicoes, eventos, subeventos });

  } catch (error) {
    console.error('Erro na pesquisa:', error);
    return res.status(500).json({ error: 'Erro interno na busca' });
  }
});

module.exports = router;
