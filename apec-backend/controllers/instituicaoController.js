const Instituicao = require('../models/Instituicao');

// Listar todas as instituições (opcional)
exports.listarInstituicoes = async (req, res) => {
  try {
    const insts = await Instituicao.find().sort({ createdAt: -1 });
    res.json(insts);
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao listar instituições', detalhes: error.message });
  }
};

// Obter instituição por ID
exports.obterInstituicao = async (req, res) => {
  try {
    const inst = await Instituicao.findById(req.params.id);
    if (!inst) return res.status(404).json({ erro: 'Instituição não encontrada' });
    res.json(inst);
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao obter instituição', detalhes: error.message });
  }
};

// Criar nova instituição (com Cloudinary, igual eventos)
exports.criarInstituicao = async (req, res) => {
  try {
    console.log('BODY:', req.body);
    console.log('FILE:', req.file);

    const dados = req.body;

    // validações mínimas
    if (!dados.nome || !dados.email || !dados.senha) {
      return res.status(400).json({ erro: 'nome, email e senha são obrigatórios' });
    }

    // não deixar email duplicado
    const jaExiste = await Instituicao.findOne({ email: dados.email });
    if (jaExiste) {
      return res.status(409).json({ erro: 'Email já cadastrado' });
    }

    // se veio imagem, salva link do cloudinary
    if (req.file) {
      dados.imagem = req.file.path;
    }

    const novaInstituicao = new Instituicao(dados);
    await novaInstituicao.save();

    res.status(201).json(novaInstituicao);
  } catch (error) {
    res.status(400).json({ erro: 'Erro ao criar instituição', detalhes: error.message });
  }
};

// Login instituição (bem simples)
exports.loginInstituicao = async (req, res) => {
  try {
    const { email, senha } = req.body;

    const inst = await Instituicao.findOne({ email });
    if (!inst) return res.status(401).json({ erro: 'Credenciais inválidas' });

    if (inst.senha !== senha) {
      return res.status(401).json({ erro: 'Credenciais inválidas' });
    }

    // retorno mínimo pro app conseguir abrir o perfil correto
    res.json({
      instituicaoId: inst._id,
      nome: inst.nome,
      email: inst.email,
    });
  } catch (error) {
    res.status(500).json({ erro: 'Erro ao fazer login', detalhes: error.message });
  }
};
