// apec-backend/controllers/subeventosController.js
const SubEvento = require('../models/Subevento');

function parseMaybeJson(raw) {
  if (raw == null) return raw;
  if (typeof raw !== 'string') return raw;

  const s = raw.trim();
  if (!s) return raw;

  // tenta parsear apenas se “parece JSON”
  if ((s.startsWith('{') && s.endsWith('}')) || (s.startsWith('[') && s.endsWith(']'))) {
    try {
      return JSON.parse(s);
    } catch (_) {
      return raw;
    }
  }
  return raw;
}

function normalizeArtistas(dados) {
  if (dados.artistas == null) return;

  // Se vier array OK
  if (Array.isArray(dados.artistas)) {
    dados.artistas = dados.artistas.map((x) => String(x).trim()).filter(Boolean);
    return;
  }

  // Se vier JSON string tipo '["a","b"]'
  const maybe = parseMaybeJson(dados.artistas);
  if (Array.isArray(maybe)) {
    dados.artistas = maybe.map((x) => String(x).trim()).filter(Boolean);
    return;
  }

  // Se vier string "a;b,c"
  if (typeof dados.artistas === 'string') {
    dados.artistas = dados.artistas
      .split(/[;,]/)
      .map((s) => s.trim())
      .filter(Boolean);
  }
}

function normalizeJogoObjects(dados) {
  if (dados.jogo != null) dados.jogo = parseMaybeJson(dados.jogo);
  if (dados.jogoNatacao != null) dados.jogoNatacao = parseMaybeJson(dados.jogoNatacao);
}

function normalizeHora(dados) {
  // padroniza: se vier "hora", salva em "horario"
  if (!dados.horario && dados.hora) dados.horario = dados.hora;
  // opcional: se vier horario e não vier hora, pode preencher hora (se quiser manter ambos)
  if (!dados.hora && dados.horario) dados.hora = dados.horario;
}

function normalizeCategoriaTexto(dados) {
  // Categoria: texto da row (padrão "Nova categoria")
  dados.categoria = (dados.categoria || 'Nova categoria').toString().trim();
  if (!dados.categoria) dados.categoria = 'Nova categoria';
}

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

    // Normalizações importantes (multipart costuma mandar strings)
    normalizeHora(dados);
    normalizeCategoriaTexto(dados);
    normalizeJogoObjects(dados);
    normalizeArtistas(dados);

    // Obrigatórios
    if (!dados.nome || !dados.data || !dados.horario || !dados.local) {
      return res.status(400).json({
        erro: 'Campos obrigatórios faltando',
        detalhes: 'Obrigatórios: nome, data, horario (ou hora), local',
      });
    }
    if (!dados.instituicaoId) {
      return res.status(400).json({ erro: 'instituicaoId é obrigatório' });
    }
    if (!dados.eventoPaiId) {
      return res.status(400).json({ erro: 'eventoPaiId é obrigatório' });
    }

    // imagem
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
    return res.status(400).json({ erro: 'Erro ao criar subevento', detalhes: error.message });
  }
};

exports.atualizarSubEvento = async (req, res) => {
  try {
    const dados = { ...req.body };

    // Normalizações
    normalizeHora(dados);
    normalizeCategoriaTexto(dados);
    normalizeJogoObjects(dados);
    normalizeArtistas(dados);

    // se veio arquivo, atualiza a imagem
    if (req.file) {
      dados.imagem = req.file.path;
    }

    const atualizado = await SubEvento.findByIdAndUpdate(req.params.id, dados, {
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
