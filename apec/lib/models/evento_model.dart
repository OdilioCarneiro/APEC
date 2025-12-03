class Evento {
  final String? id;
  final String nome;
  final String categoria; // esportiva, cultural, institucional
  final String descricao;
  final String data; // YYYY-MM-DD
  final String horario; // HH:mm
  final String local;
  final String imagem;
  final String? categoriaEsportiva;
  final String? genero;
  final String? tema;
  final String? categoriaCultural;
  final List<String>? artistas;

  Evento({
    this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.data,
    required this.horario,
    required this.local,
    required this.imagem,
    this.categoriaEsportiva,
    this.genero,
    this.tema,
    this.categoriaCultural,
    this.artistas,
  });

  /// Converter Evento para JSON (para enviar à API)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'data': data,
      'horario': horario,
      'local': local,
      'imagem': imagem,
      'categoriaEsportiva': categoriaEsportiva,
      'genero': genero,
      'tema': tema,
      'categoriaCultural': categoriaCultural,
      'artistas': artistas,
    };
  }

  /// Criar Evento a partir de JSON (da API)
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['_id'],
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? '',
      descricao: json['descricao'] ?? '',
      data: json['data'] ?? '',
      horario: json['horario'] ?? '',
      local: json['local'] ?? '',
      imagem: json['imagem'] ?? '',
      categoriaEsportiva: json['categoriaEsportiva'],
      genero: json['genero'],
      tema: json['tema'],
      categoriaCultural: json['categoriaCultural'],
      artistas: json['artistas'] != null ? List<String>.from(json['artistas']) : null,
    );
  }
}
