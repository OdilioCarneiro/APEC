const express = require('express');
const router = express.Router();
const path = require('path');
const multer = require('multer');
const { v2: cloudinary } = require('cloudinary');
const eventoController = require('../controllers/eventoController');

// Configuração Cloudinary (use .env para o secret)
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,  // ex: 'dncqbrkuq'
  api_key: process.env.CLOUDINARY_API_KEY,        // ex: '4882215...'
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Multer: salva arquivo temporário em /tmp (ok para Render)
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, '/tmp'),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

// Rotas para eventos
router.get('/', eventoController.listarEventos);
router.get('/:id', eventoController.obterEvento);

// Criar evento com upload de imagem
router.post(
  '/',
  upload.single('imagem'),          // campo 'imagem' virá do Flutter
  async (req, res) => {
    try {
      let imageUrl = '';

      if (req.file) {
        const resultado = await cloudinary.uploader.upload(req.file.path);
        imageUrl = resultado.secure_url;         // URL pública da imagem
      }

      // combina body original + URL da imagem
      req.body.imagem = imageUrl;

      // reaproveita o controller que você já tem
      return eventoController.criarEvento(req, res);
    } catch (error) {
      console.error(error);
      return res
        .status(500)
        .json({ erro: 'Erro no upload da imagem', detalhes: error.message });
    }
  }
);

router.put('/:id', eventoController.atualizarEvento);
router.delete('/:id', eventoController.deletarEvento);
router.get('/categoria/:categoria', eventoController.listarEventosPorCategoria);

module.exports = router;
