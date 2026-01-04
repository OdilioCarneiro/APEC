const Evento = require('../models/Evento');
const Instituicao = require('../models/Instituicao');
const Subevento = require('../models/Subevento');

exports.pesquisarTudo = async (req, res) => {
  try {
    const { q } = req.query;
    
    // Se a busca for vazia, retorna tudo vazio
    if (!q || q.trim() === '') {
      return res.json({ eventos: [], instituicoes: [], subeventos: [] });
    }

    // Cria uma expressão regular "case insensitive" (ignora maiúscula/minúscula)
    // O 'i' significa insensitive.
    // Isso permite buscar partes da palavra. Ex: "tec" acha "Tecnologia"
    const regex = new RegExp(q.trim(), 'i');

    const [eventos, instituicoes, subeventos] = await Promise.all([
      // Busca em Eventos (Nome OU Descrição OU Local)
      Evento.find({
        $or: [
          { nome: regex },
          { descricao: regex },
          { local: regex },
          { artistas: regex }
        ]
      })
      .populate('instituicaoId', 'nome')
      .limit(10),

      // Busca em Instituições (Nome OU Sigla)
      Instituicao.find({
        $or: [
          { nome: regex },
          { sigla: regex }
        ]
      }).limit(5),

      // Busca em Subeventos (Título OU Palestrante)
      Subevento.find({
        $or: [
          { titulo: regex },
          { palestrante: regex }
        ]
      })
      .populate('eventoId', 'nome')
      .limit(5)
    ]);

    res.json({ eventos, instituicoes, subeventos });

  } catch (error) {
    console.error('Erro na busca:', error);
    res.status(500).json({ msg: 'Erro ao buscar dados' });
  }
};
