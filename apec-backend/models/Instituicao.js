const mongoose = require('mongoose');

const instituicaoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    campus: { type: String, default: '', trim: true },
    bio: { type: String, default: '', trim: true },

    email: { type: String, required: true, unique: true, lowercase: true, trim: true },

    // (igual eventos: recebe url do cloudinary via req.file.path)
    imagem: { type: String, default: '' },

    // por enquanto salva a senha direto (não recomendado).
    // se quiser, eu te mando a versão com bcrypt + senhaHash.
    senha: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Instituicao', instituicaoSchema);
