const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController');
const upload = require('../middlewares/multer');

// Rotas para eventos
router.get('/', eventoController.listarEventos);
router.get('/:id', eventoController.obterEvento);

// ✅ ROTA POST CORRETA COM CLOUDINARY
router.post(
  '/',
  upload.single('file'),
  eventoController.criarEvento
);

router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);

module.exports = router;
