const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController');
const upload = require('../middlewares/multer');

router.get('/', eventoController.listarEventos);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);
router.get('/instituicao/:instituicaoId', eventoController.listarEventosPorInstituicao);

router.post('/', upload.single('file'), eventoController.criarEvento);

router.put('/:id/renomear-categoria', eventoController.renomearCategoriaSubeventos);

router.get('/:id', eventoController.obterEvento);
router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);

module.exports = router;
