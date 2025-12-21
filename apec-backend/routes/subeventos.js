// apec-backend/routes/subeventos.js
const express = require('express');
const router = express.Router();

const subeventosController = require('../controllers/subeventosController');
const upload = require('../middlewares/multer'); // se você já usa multer no projeto

router.get('/', subeventosController.listarSubEventos);
router.get('/:id', subeventosController.obterSubEvento);

router.post(
  '/',
  upload.single('imagem'), // opcional; se não for enviar imagem, ainda funciona
  subeventosController.criarSubEvento
);

router.put('/:id', subeventosController.atualizarSubEvento);
router.delete('/:id', subeventosController.deletarSubEvento);

module.exports = router;
