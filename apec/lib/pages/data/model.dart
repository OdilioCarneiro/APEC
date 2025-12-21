// ---------------- INSTITUIÇÃO ----------------

class Instituicao {
  String? id;
  String? nome;
  String? descricao;

  /// Aqui é a URL (backend pode mandar fotoUrl ou imagem)
  String imagem;

  String email;
  String senha;

  Instituicao({
    this.id,
    this.nome,
    this.descricao,
    required this.imagem,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
      'email': email,
      'senha': senha,
    };
  }

  /// Aceita:
  /// - Map populado: {_id, nome, fotoUrl/imagem}
  /// - String: id puro
  factory Instituicao.fromAPI(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Instituicao(
        id: (raw['_id'] ?? raw['id'] ?? '').toString(),
        nome: (raw['nome'] ?? '').toString(),
        descricao: (raw['descricao'] ?? raw['bio'] ?? '').toString(),
        imagem: (raw['fotoUrl'] ?? raw['imagem'] ?? '').toString(),
        email: (raw['email'] ?? '').toString(),
        senha: (raw['senha'] ?? '').toString(),
      );
    }

    return Instituicao(
      id: raw?.toString(),
      nome: '',
      descricao: '',
      imagem: '',
      email: '',
      senha: '',
    );
  }

  Instituicao copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? imagem,
    String? email,
    String? senha,
  }) {
    return Instituicao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      imagem: imagem ?? this.imagem,
      email: email ?? this.email,
      senha: senha ?? this.senha,
    );
  }
}

// ---------------- ENUMS BÁSICOS ----------------

enum Genero { masculino, feminino, outros }

enum CategoriEspotiva {
  futebol,
  basquete,
  voleibol,
  corrida,
  ciclismo,
  carimba,
  natacao,
  artesMarciais,
  handeboll,
  tenis,
}

enum Categoria { esportiva, cultural }

// cultural
enum CategoriaCultural { musica, teatro, danca, exposicao, cinema, literatura }

// ---------------- ESPORTIVO ----------------

class Jogo {
  String timeA;
  String timeB;
  int placarA;
  int placarB;
  String data;
  String local;

  Jogo({
    required this.timeA,
    required this.timeB,
    required this.placarA,
    required this.placarB,
    required this.data,
    required this.local,
  });

  Map<String, dynamic> toMap() {
    return {
      'timeA': timeA,
      'timeB': timeB,
      'placarA': placarA,
      'placarB': placarB,
      'data': data,
      'local': local,
    };
  }
}

enum ModalidadeNatacao { crawl, costas, peito, borboleta, medley }

class JogoNatacao {
  String atleta;
  ModalidadeNatacao modalidade;
  String tempo;
  String data;

  JogoNatacao({
    required this.atleta,
    required this.modalidade,
    required this.tempo,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'atleta': atleta,
      'modalidade': modalidade.name,
      'tempo': tempo,
      'data': data,
    };
  }
}

// ---------------- SUBEVENTO ----------------

class CategoriaSubevento {
  final String id;
  final String titulo;
  final int ordem;

  const CategoriaSubevento({
    required this.id,
    required this.titulo,
    required this.ordem,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'ordem': ordem,
      };

  factory CategoriaSubevento.fromAPI(Map<String, dynamic> json) {
    return CategoriaSubevento(
      id: (json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      ordem: (json['ordem'] is num) ? (json['ordem'] as num).toInt() : 0,
    );
  }

  CategoriaSubevento copyWith({String? id, String? titulo, int? ordem}) {
    return CategoriaSubevento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      ordem: ordem ?? this.ordem,
    );
  }
}

class SubEvento {
  final String id;
  final String categoriaId;
  final String nome;
  final String descricao;
  final String data;
  final String hora;
  final String local;

  /// Pode ser URL (quando tiver backend) ou path local (enquanto está local)
  final String imagem;

  final String? videoUrl;
  final String? fotosUrl;

  /// Agora é texto livre (ex.: "2x1", "W.O.", "Final A", "3 sets a 0")
  final String? placar;

  SubEvento({
    required this.id,
    required this.categoriaId,
    required this.nome,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.local,
    required this.imagem,
    this.videoUrl,
    this.fotosUrl,
    this.placar,
  });

  factory SubEvento.fromAPI(Map<String, dynamic> j) {
    String? _norm(String? v) {
      final s = (v ?? '').trim();
      return s.isEmpty ? null : s;
    }

    return SubEvento(
      id: (j['id'] ?? '').toString(),
      categoriaId: (j['categoriaId'] ?? '').toString(),
      nome: (j['nome'] ?? '').toString(),
      descricao: (j['descricao'] ?? '').toString(),
      data: (j['data'] ?? '').toString(),
      hora: (j['hora'] ?? '').toString(),
      local: (j['local'] ?? '').toString(),
      imagem: (j['imagem'] ?? '').toString(),
      videoUrl: _norm(j['videoUrl']?.toString()),
      fotosUrl: _norm(j['fotosUrl']?.toString()),
      placar: _norm(j['placar']?.toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoriaId': categoriaId,
        'nome': nome,
        'descricao': descricao,
        'data': data,
        'hora': hora,
        'local': local,
        'imagem': imagem,
        'videoUrl': videoUrl,
        'fotosUrl': fotosUrl,
        'placar': placar,
      };
}


// ---------------- EVENTO ----------------

class Evento {
  String? id;
  String nome;
  Categoria categoria;
  String descricao;
  String data;
  String horario;
  String imagem;
  String local;

  /// DONO
  String? instituicaoId;
  Instituicao? instituicao;

  // esportivo
  CategoriEspotiva? categoriaEsportiva;
  Genero? genero;
  Jogo? jogo;
  JogoNatacao? jogoNatacao;

  // cultural
  String? tema;
  CategoriaCultural? categoriaCultural;
  List<String>? artistas;

  // links
  Uri? linkInscricao;
  Uri? linkTransmissao;
  Uri? linkResultados;
  Uri? linkFotos;

  // >>> subeventos
  List<CategoriaSubevento> categoriasSubeventos;
  List<SubEvento> subeventos;

  Evento({
    this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.data,
    required this.local,
    required this.imagem,
    required this.horario,
    this.instituicaoId,
    this.instituicao,
    this.categoriaEsportiva,
    this.genero,
    this.jogo,
    this.jogoNatacao,
    this.tema,
    this.categoriaCultural,
    this.artistas,
    this.linkInscricao,
    this.linkTransmissao,
    this.linkResultados,
    this.linkFotos,
    List<CategoriaSubevento>? categoriasSubeventos,
    List<SubEvento>? subeventos,
  })  : categoriasSubeventos = categoriasSubeventos ?? [],
        subeventos = subeventos ?? [];

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'nome': nome,
      'categoria': categoria.name,
      'descricao': descricao,
      'data': data,
      'horario': horario,
      'imagem': imagem,
      'local': local,
      'instituicaoId': instituicaoId ?? instituicao?.id,
      'categoriaEsportiva': categoriaEsportiva?.name,
      'genero': genero?.name,
      'jogo': jogo?.toMap(),
      'jogoNatacao': jogoNatacao?.toMap(),
      'tema': tema,
      'categoriaCultural': categoriaCultural?.name,
      'artistas': artistas,
      'linkInscricao': linkInscricao?.toString(),
      'linkTransmissao': linkTransmissao?.toString(),
      'linkResultados': linkResultados?.toString(),
      'linkFotos': linkFotos?.toString(),

      // >>> subeventos
      'categoriasSubeventos': categoriasSubeventos.map((e) => e.toMap()).toList(),
      'subeventos': subeventos.map((e) => e.toMap()).toList(),
    };
  }

  factory Evento.fromAPI(Map<String, dynamic> json) {
    final instRaw = json['instituicaoId'];

    String? instId;
    Instituicao? inst;

    if (instRaw is Map<String, dynamic>) {
      inst = Instituicao.fromAPI(instRaw);
      instId = inst.id;
    } else if (instRaw != null) {
      instId = instRaw.toString();
    }

    return Evento(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      categoria: _parseCategoria(json['categoria']?.toString()),
      descricao: (json['descricao'] ?? '').toString(),
      data: (json['data'] ?? '').toString(),
      horario: (json['horario'] ?? '').toString(),
      local: (json['local'] ?? '').toString(),
      imagem: (json['imagem'] ?? '').toString(),
      instituicaoId: instId,
      instituicao: inst,
      categoriaEsportiva: json['categoriaEsportiva'] != null
          ? _parseCategoriEspotiva(json['categoriaEsportiva']?.toString())
          : null,
      genero: json['genero'] != null ? _parseGenero(json['genero']?.toString()) : null,
      tema: json['tema']?.toString(),
      categoriaCultural: json['categoriaCultural'] != null
          ? _parseCategoriaCultural(json['categoriaCultural']?.toString())
          : null,
      artistas: _parseArtistas(json['artistas']),

      // >>> subeventos
      categoriasSubeventos: (json['categoriasSubeventos'] is List)
          ? (json['categoriasSubeventos'] as List)
              .whereType<Map<String, dynamic>>()
              .map(CategoriaSubevento.fromAPI)
              .toList()
          : <CategoriaSubevento>[],
      subeventos: (json['subeventos'] is List)
          ? (json['subeventos'] as List)
              .whereType<Map<String, dynamic>>()
              .map(SubEvento.fromAPI)
              .toList()
          : <SubEvento>[],
    );
  }

  Evento copyWith({
    String? id,
    String? nome,
    Categoria? categoria,
    String? descricao,
    String? data,
    String? horario,
    String? imagem,
    String? local,
    String? instituicaoId,
    Instituicao? instituicao,
    CategoriEspotiva? categoriaEsportiva,
    Genero? genero,
    Jogo? jogo,
    JogoNatacao? jogoNatacao,
    String? tema,
    CategoriaCultural? categoriaCultural,
    List<String>? artistas,
    Uri? linkInscricao,
    Uri? linkTransmissao,
    Uri? linkResultados,
    Uri? linkFotos,
    List<CategoriaSubevento>? categoriasSubeventos,
    List<SubEvento>? subeventos,
  }) {
    return Evento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      horario: horario ?? this.horario,
      imagem: imagem ?? this.imagem,
      local: local ?? this.local,
      instituicaoId: instituicaoId ?? this.instituicaoId,
      instituicao: instituicao ?? this.instituicao,
      categoriaEsportiva: categoriaEsportiva ?? this.categoriaEsportiva,
      genero: genero ?? this.genero,
      jogo: jogo ?? this.jogo,
      jogoNatacao: jogoNatacao ?? this.jogoNatacao,
      tema: tema ?? this.tema,
      categoriaCultural: categoriaCultural ?? this.categoriaCultural,
      artistas: artistas ?? this.artistas,
      linkInscricao: linkInscricao ?? this.linkInscricao,
      linkTransmissao: linkTransmissao ?? this.linkTransmissao,
      linkResultados: linkResultados ?? this.linkResultados,
      linkFotos: linkFotos ?? this.linkFotos,
      categoriasSubeventos: categoriasSubeventos ?? this.categoriasSubeventos,
      subeventos: subeventos ?? this.subeventos,
    );
  }

  // ---------------- HELPERS ESTÁTICOS ----------------

  static List<String>? _parseArtistas(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;
      return s.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }

  static Categoria _parseCategoria(String? value) {
    switch (value) {
      case 'esportiva':
        return Categoria.esportiva;
      case 'cultural':
        return Categoria.cultural;
      default:
        return Categoria.esportiva;
    }
  }

  static CategoriEspotiva? _parseCategoriEspotiva(String? value) {
    if (value == null) return null;
    try {
      return CategoriEspotiva.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static Genero? _parseGenero(String? value) {
    if (value == null) return null;
    try {
      return Genero.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static CategoriaCultural? _parseCategoriaCultural(String? value) {
    if (value == null) return null;
    try {
      return CategoriaCultural.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
