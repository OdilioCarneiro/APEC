const mongoose = require('mongoose');

const EventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    categoria: { type: String, required: true, trim: true },
    descricao: { type: String, default: '' },
    data: { type: String, required: true },      // ex.: "YYYY-MM-DD"
    horario: { type: String, required: true },
    local: { type: String, required: true, trim: true },

    imagem: { type: String, default: '' },

    // Referência para poder usar populate()
    instituicaoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Instituicao',
      required: true,
    },

    // Categorias de subeventos (lista de títulos)
    // models/Evento.js
    categoriasSubeventos: {
      type: [String],
      default: ['Nova categoria'],
    },



    categoriaEsportiva: { type: String, default: '' },
    genero: { type: String, default: '' },

    tema: { type: String, default: '' },
    categoriaCultural: { type: String, default: '' },

    artistas: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Evento', EventoSchema);
