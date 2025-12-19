const mongoose = require('mongoose');

const eventoSchema = new mongoose.Schema(
  {
    nome: {
      type: String,
      required: true,
      trim: true,
    },
    categoria: {
      type: String,
      enum: ['esportiva', 'cultural', 'institucional'],
      required: true,
    },
    descricao: {
      type: String,
      trim: true,
    },
    data: {
      type: String, // formato YYYY-MM-DD
      required: true,
    },
    horario: {
      type: String, // formato HH:mm
      required: true,
    },
    local: {
      type: String,
      required: true,
      trim: true,
    },
    imagem: {
      type: String, // URL ou caminho da imagem
      default: '',
    },
    // Campos específicos para eventos esportivos
    categoriaEsportiva: {
      type: String, // ex: futebol, vôlei, etc
      default: null,
    },
    genero: {
      type: String,
      enum: ['masculino', 'feminino', 'misto', null],
      default: null,
    },
    // Campos específicos para eventos culturais
    tema: {
      type: String,
      default: null,
    },
    categoriaCultural: {
      type: String, // ex: música, teatro, dança, etc
      default: null,
    },
    artistas: [
      {
        type: String,
      },
    ],
    // Metadados
    criadoEm: {
      type: Date,
      default: Date.now,
    },
    atualizadoEm: {
      type: Date,
      default: Date.now,
    },

    instituicaoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Instituicao',
      required: false, // pode colocar true quando você tiver login obrigatório
    },

  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Evento', eventoSchema);
