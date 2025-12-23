const express = require('express');
const router = express.Router();

const instituicaoController = require('../controllers/instituicaoController');
const upload = require('../middlewares/multer');

router.get('/ping', (req, res) => res.json({ ok: true }));

router.get('/', instituicaoController.listarInstituicoes);
router.get('/:id', instituicaoController.obterInstituicao);

router.post(
  '/',
  upload.single('file'),
  instituicaoController.criarInstituicao
);

router.post('/login', instituicaoController.loginInstituicao);

router.put(
  '/:id',
  upload.single('file'),
  instituicaoController.atualizarInstituicao
);

router.delete('/:id', instituicaoController.deletarInstituicao);

module.exports = router;
