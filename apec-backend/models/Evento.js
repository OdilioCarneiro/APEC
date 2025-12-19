const mongoose = require('mongoose');

const EventoSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true },
    categoria: { type: String, required: true, trim: true },
    descricao: { type: String, default: '' },
    data: { type: String, required: true },     // se você usa "YYYY-MM-DD"
    horario: { type: String, required: true },
    local: { type: String, required: true, trim: true },

    imagem: { type: String, default: '' },

    // >>> o PULO DO GATO: referencia real pra poder populate()
    instituicaoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Instituicao',
      required: true,
    },

    // campos opcionais
    categoriaEsportiva: { type: String, default: '' },
    genero: { type: String, default: '' },

    tema: { type: String, default: '' },
    categoriaCultural: { type: String, default: '' },
    artistas: { type: String, default: '' }, // string "a;b;c"
  },
  { timestamps: true }
);

module.exports = mongoose.model('Evento', EventoSchema);
