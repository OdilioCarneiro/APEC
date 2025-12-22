const mongoose = require('mongoose');

const SubEventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },

    // categoria (row)
    categoria: { type: String, trim: true, default: 'Subeventos' },

    data: { type: String, required: true },
    horario: { type: String, required: true },
    local: { type: String, required: true, trim: true },

    descricao: { type: String, default: '' },
    imagem: { type: String, default: '' },

    videoUrl: { type: String, default: '' },
    fotosUrl: { type: String, default: '' },
    placar: { type: String, default: '' },

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
