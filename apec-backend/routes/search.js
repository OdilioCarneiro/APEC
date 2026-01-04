const router = require('express').Router();
const mongoose = require('mongoose');

// Importar os Models
const Instituicao = require('../models/Instituicao');
const Evento = require('../models/Evento');
const Subevento = require('../models/Subevento');

// === FUNÇÕES DE AJUDA ===

// 1. Remove acentos (ex: "Apresentação" -> "Apresentacao")
function removerAcentos(str) {
  if (!str) return "";
  return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

// 2. Cria um Regex que aceita todas as variações de cada letra
function criarRegexBlindado(textoUsuario) {
  // Primeiro limpa o texto do usuário
  const limpo = removerAcentos(textoUsuario);

  // Transforma cada letra num grupo que aceita acentos
  const padrao = limpo.split('').map(char => {
    if (/[aA]/.test(char)) return '[aáàâãäAÁÀÂÃÄ]';
    if (/[eE]/.test(char)) return '[eéèêëEÉÈÊË]';
    if (/[iI]/.test(char)) return '[iíìîïIÍÌÎÏ]';
    if (/[oO]/.test(char)) return '[oóòôõöOÓÒÔÕÖ]';
    if (/[uU]/.test(char)) return '[uúùûüUÚÙÛÜ]';
    if (/[cC]/.test(char)) return '[cçCÇ]';
    
    // Escapa caracteres especiais de regex (como . * +)
    return char.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
  }).join('');

  // Retorna o regex final com flag 'i' (ignora maiúsculo/minúsculo)
  return new RegExp(padrao, 'i');
}

// === ROTA ===
router.get('/', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) return res.json({ instituicoes: [], eventos: [], subeventos: [] });

    const regex = criarRegexBlindado(q);
    
    // Para debug no log do servidor
    console.log(`Input: ${q} | Regex: ${regex}`);

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

      // Evento (Procura em titulo E nome para garantir)
      Evento.find({
        $or: [
          { nome: regex },
          { titulo: regex }, 
          { descricao: regex },
          { local: regex },
          { categoria: regex }
        ]
      }).populate('instituicaoId', 'nome imagem'),

      // Subevento (Procura em titulo E nome para garantir)
      Subevento.find({
        $or: [
          { nome: regex },
          { titulo: regex },
          { descricao: regex },
          { tema: regex }
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
