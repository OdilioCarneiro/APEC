const Instituicao = require('../models/Instituicao');
const Evento = require('../models/Evento');
const SubEvento = require('../models/Subevento');

exports.listarInstituicoes = async (req, res) => {
  try {
    const list = await Instituicao.find().lean();
    return res.json(list);
  } catch (e) {
    return res.status(500).json({ error: String(e) });
  }
};

exports.obterInstituicao = async (req, res) => {
  try {
    const { id } = req.params;
    const inst = await Instituicao.findById(id).lean();
    if (!inst) return res.status(404).json({ error: 'Instituição não encontrada' });
    return res.json(inst);
  } catch (e) {
    return res.status(500).json({ error: String(e) });
  }
};

exports.criarInstituicao = async (req, res) => {
  try {
    const { nome, campus, bio, email, senha } = req.body;

    if (!nome || !email || !senha) {
      return res.status(400).json({ error: 'nome, email e senha são obrigatórios' });
    }

    const data = {
      nome: String(nome).trim(),
      campus: campus ? String(campus).trim() : '',
      bio: bio ? String(bio).trim() : '',
      email: String(email).trim().toLowerCase(),
      senha: String(senha).trim(),
    };

    if (req.file && req.file.path) {
      data.imagem = req.file.path;
    }

    const inst = await Instituicao.create(data);
    return res.status(201).json(inst);
  } catch (e) {
    if (e.code === 11000) return res.status(409).json({ error: 'Email já cadastrado' });
    return res.status(500).json({ error: String(e) });
  }
};

exports.loginInstituicao = async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    const inst = await Instituicao.findOne({
      email: String(email).trim().toLowerCase(),
      senha: String(senha).trim(),
    });

    if (!inst) return res.status(401).json({ error: 'Credenciais inválidas' });

    return res.json({ instituicaoId: inst._id, instituicao: inst });
  } catch (e) {
    return res.status(500).json({ error: String(e) });
  }
};

exports.atualizarInstituicao = async (req, res) => {
  try {
    const { id } = req.params;

    const update = {};
    if (req.body.nome != null) update.nome = String(req.body.nome).trim();
    if (req.body.campus != null) update.campus = String(req.body.campus).trim();
    if (req.body.bio != null) update.bio = String(req.body.bio).trim();
    if (req.body.email != null) update.email = String(req.body.email).trim().toLowerCase();

    if (req.body.senha != null && String(req.body.senha).trim() !== '') {
      update.senha = String(req.body.senha).trim();
    }

    if (req.file && req.file.path) {
      update.imagem = req.file.path;
    }

    const inst = await Instituicao.findByIdAndUpdate(id, { $set: update }, { new: true });
    if (!inst) return res.status(404).json({ error: 'Instituição não encontrada' });

    return res.json(inst);
  } catch (e) {
    if (e.code === 11000) return res.status(409).json({ error: 'Email já cadastrado' });
    return res.status(500).json({ error: String(e) });
  }
};

exports.deletarInstituicao = async (req, res) => {
  try {
    const { id } = req.params;

    const inst = await Instituicao.findById(id);
    if (!inst) return res.status(404).json({ error: 'Instituição não encontrada' });

    const eventos = await Evento.find({ instituicaoId: id }).select('_id').lean();
    const eventoIds = eventos.map((e) => e._id);

    if (eventoIds.length > 0) {
      await SubEvento.deleteMany({ eventoPaiId: { $in: eventoIds } });
      await Evento.deleteMany({ _id: { $in: eventoIds } });
    }

    await Instituicao.findByIdAndDelete(id);
    return res.status(204).send();
  } catch (e) {
    console.error('Erro ao deletar instituição:', e);
    return res.status(500).json({ error: String(e) });
  }
};
