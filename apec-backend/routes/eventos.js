const express = require('express');
const router = express.Router();
const eventoController = require('../controllers/eventoController'); 
const upload = require('../middlewares/multer'); // ✅ CLOUDINARY

// Rotas
router.get('/', eventoController.listarEventos);
router.get('/:id', eventoController.obterEvento);

router.post(
  '/',
  upload.single('imagem'),         // ✅ CAMPO "imagem" DO FLUTTER
  eventoController.criarEvento     // ✅ MESMO NOME DO REQUIRE
);

router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);

module.exports = router;
