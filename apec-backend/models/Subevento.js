// apec-backend/models/SubEvento.js
const mongoose = require('mongoose');

const SubEventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    data: { type: String, required: true },      // mantenha como você já usa (string)
    horario: { type: String, required: true },   // idem
    local: { type: String, required: true, trim: true },

    descricao: { type: String, default: '' },
    imagem: { type: String, default: '' },

    instituicaoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Instituicao',
      required: true,
    },

    eventoPaiId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Evento',
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('SubEvento', SubEventoSchema);
