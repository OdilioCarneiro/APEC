const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController');

// Rotas para eventos
router.get('/', eventoController.listarEventos);
router.get('/:id', eventoController.obterEvento);
router.post('/', eventoController.criarEvento);
router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);

module.exports = router;
