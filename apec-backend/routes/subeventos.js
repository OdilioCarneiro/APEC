const express = require('express');
const multer = require('multer');
const subeventosController = require('../controllers/subeventosController');

const router = express.Router();

// igual ao exemplo clássico: salva em uploads/
const upload = multer({ dest: 'uploads/' });

router.get('/', subeventosController.listarSubEventos);
router.get('/:id', subeventosController.obterSubEvento);
router.post('/', upload.single('file'), subeventosController.criarSubEvento);
router.put('/:id', subeventosController.atualizarSubEvento);
router.delete('/:id', subeventosController.deletarSubEvento);

module.exports = router;
