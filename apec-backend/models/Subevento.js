const mongoose = require('mongoose');

const SubEventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    categoria: { type: String, default: 'Subeventos', trim: true },

    descricao: { type: String, default: '' },
    data: { type: String, required: true }, // "YYYY-MM-DD"
    horario: { type: String, required: true }, // "HH:mm"
    local: { type: String, required: true, trim: true },

    placar: { type: String, default: '' },
    fotosUrl: { type: String, default: '' },
    videoUrl: { type: String, default: '' },

    imagem: { type: String, default: '' },

    // liga no Evento pai
    eventoPaiId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Evento',
      required: true,
    },

    // segue seu padrão do Evento: instituição obrigatória
    instituicaoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Instituicao',
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('SubEvento', SubEventoSchema);
