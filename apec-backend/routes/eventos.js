const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController');
const upload = require('../middlewares/multer');

// GETs
router.get('/', eventoController.listarEventos);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);
router.get('/instituicao/:instituicaoId', eventoController.listarEventosPorInstituicao);

// POST
router.post('/', upload.single('file'), eventoController.criarEvento);

// ROTA DE RENAME (antes de /:id)
router.put('/:id/renomear-categoria', eventoController.renomearCategoriaSubeventos);

// CRUD por id
router.get('/:id', eventoController.obterEvento);
router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);

module.exports = router;
