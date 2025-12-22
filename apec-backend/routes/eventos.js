const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController');
const upload = require('../middlewares/multer');

// GETs específicos primeiro
router.get('/', eventoController.listarEventos);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);
router.get('/instituicao/:instituicaoId', eventoController.listarEventosPorInstituicao);

// POST
router.post('/', upload.single('file'), eventoController.criarEvento);

// ROTA NOVA (tem que vir antes do /:id)
router.put('/:id/renomear-categoria', eventoController.renomearCategoriaSubeventos);
router.get('/:id', eventoController.obterEvento);
router.put('/:id', eventoController.atualizarEvento);


// :id por último
router.get('/:id', eventoController.obterEvento);
router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);

module.exports = router;
