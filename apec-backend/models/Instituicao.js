const mongoose = require('mongoose');

// Mudei para Maiúscula aqui para bater com o final do arquivo
const InstituicaoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    campus: { type: String, default: '', trim: true },
    bio: { type: String, default: '', trim: true },

    email: { type: String, required: true, unique: true, lowercase: true, trim: true },

    // (igual eventos: recebe url do cloudinary via req.file.path)
    imagem: { type: String, default: '' },

    // Senha direta
    senha: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

// CORRIGIDO: 
// 1. Nome da variável agora bate (InstituicaoSchema)
// 2. Troquei 'sigla' (que não existia) por 'campus' e 'bio'
InstituicaoSchema.index({ nome: 'text', campus: 'text', bio: 'text' });

module.exports = mongoose.model('Instituicao', InstituicaoSchema);
