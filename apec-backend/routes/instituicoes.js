const express = require('express');
const router = express.Router();

const instituicaoController = require('../controllers/instituicaoController');
const upload = require('../middlewares/multer');

router.get('/ping', (req, res) => res.json({ ok: true }));

// Rotas para instituições
router.get('/', instituicaoController.listarInstituicoes); // opcional
router.get('/:id', instituicaoController.obterInstituicao);

// cadastro com imagem (igual eventos)
router.post(
  '/',
  upload.single('file'),
  instituicaoController.criarInstituicao
);

// login
router.post('/login', instituicaoController.loginInstituicao);

module.exports = router;
