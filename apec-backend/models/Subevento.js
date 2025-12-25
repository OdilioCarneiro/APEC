const mongoose = require('mongoose');

const SubEventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    categoria: { type: String, trim: true, default: 'Nova categoria' },

    data: { type: String, required: true },     // "YYYY-MM-DD"
    horario: { type: String, required: true },  // "HH:mm"
    local: { type: String, required: true, trim: true },

    descricao: { type: String, default: '' },
    imagem: { type: String, default: '' },

    videoUrl: { type: String, default: '' },
    fotosUrl: { type: String, default: '' },
    placar: { type: String, default: '' },

    // ===== NOVOS CAMPOS =====
    tipo: { type: String, enum: ['esportiva', 'cultural'], default: null },

    categoriaEsportiva: { type: String, default: null },
    genero: { type: String, default: null },

    tema: { type: String, default: '' },
    categoriaCultural: { type: String, default: null },
    artistas: { type: [String], default: [] },

    jogo: {
      timeA: { type: String, default: '' },
      timeB: { type: String, default: '' },
      placarA: { type: Number, default: 0 },
      placarB: { type: Number, default: 0 },
      data: { type: String, default: '' },
      local: { type: String, default: '' },
    },

    jogoNatacao: {
      atleta: { type: String, default: '' },
      modalidade: { type: String, default: '' },
      tempo: { type: String, default: '' },
      data: { type: String, default: '' },
    },

    instituicaoId: { type: mongoose.Schema.Types.ObjectId, ref: 'Instituicao', required: true },
    eventoPaiId: { type: mongoose.Schema.Types.ObjectId, ref: 'Evento', required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('SubEvento', SubEventoSchema);
