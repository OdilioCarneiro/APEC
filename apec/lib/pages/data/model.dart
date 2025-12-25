// model.dart
// Modelos do app (Instituição, Evento, SubEvento, etc.)

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

// ATUALIZADO: Agora inclui "ambos"
enum Categoria { esportiva, cultural, ambos }

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

  factory Jogo.fromAPI(Map<String, dynamic> j) {
    int _toInt(dynamic v) => int.tryParse((v ?? '0').toString()) ?? 0;

    return Jogo(
      timeA: (j['timeA'] ?? '').toString(),
      timeB: (j['timeB'] ?? '').toString(),
      placarA: _toInt(j['placarA']),
      placarB: _toInt(j['placarB']),
      data: (j['data'] ?? '').toString(),
      local: (j['local'] ?? '').toString(),
    );
  }

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

  factory JogoNatacao.fromAPI(Map<String, dynamic> j) {
    ModalidadeNatacao _parseModalidade(String? v) {
      if (v == null) return ModalidadeNatacao.crawl;
      try {
        return ModalidadeNatacao.values.firstWhere((e) => e.name == v);
      } catch (_) {
        return ModalidadeNatacao.crawl;
      }
    }

    return JogoNatacao(
      atleta: (j['atleta'] ?? '').toString(),
      modalidade: _parseModalidade(j['modalidade']?.toString()),
      tempo: (j['tempo'] ?? '').toString(),
      data: (j['data'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'atleta': atleta,
      'modalidade': modalidade.name,
      'tempo': tempo,
      'data': data,
    };
  }
}

// ---------------- CATEGORIA DE SUBEVENTO ----------------

class CategoriaSubevento {
  final String id;
  final String titulo;

  /// Opcional: se você tiver cor/ordem no backend, dá pra aproveitar.
  final String? corHex;
  final int? ordem;

  const CategoriaSubevento({
    required this.id,
    required this.titulo,
    this.corHex,
    this.ordem,
  });

  factory CategoriaSubevento.fromAPI(Map<String, dynamic> j) {
    int? _toIntOrNull(dynamic v) => int.tryParse((v ?? '').toString());

    return CategoriaSubevento(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      titulo: (j['titulo'] ?? j['nome'] ?? j['label'] ?? '').toString(),
      corHex: (j['corHex'] ?? j['cor'] ?? j['hex'] ?? '').toString().trim().isEmpty
          ? null
          : (j['corHex'] ?? j['cor'] ?? j['hex']).toString(),
      ordem: _toIntOrNull(j['ordem']),
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'titulo': titulo,
        if (corHex != null) 'corHex': corHex,
        if (ordem != null) 'ordem': ordem,
      };
}

// ---------------- SUBEVENTO (ATUALIZADO) ----------------

class SubEvento {
  final String id;

  /// ID da categoria (se você usar categoriasSubeventos com ids)
  final String categoriaId;

  /// Texto da categoria (ex.: "Música", "Final", etc.)
  final String? categoria;

  final String nome;
  final String descricao;
  final String data;

  /// No backend você pode mandar "horario"; em partes do app você usa "hora".
  final String hora;

  final String local;

  /// Pode ser URL (backend) ou path local (enquanto está local)
  final String imagem;

  final String? videoUrl;
  final String? fotosUrl;

  /// Texto livre (ex.: "2x1", "W.O.", etc.)
  final String? placar;

  /// IDs que costumam existir no backend (opcional no app)
  final String? eventoPaiId;
  final String? instituicaoId;

  // ========== CAMPOS MOVIDOS DO EVENTO ==========
  
  /// Tipo do subevento (esportivo ou cultural)
  final Categoria? tipo;

  // Campos esportivos
  final CategoriEspotiva? categoriaEsportiva;
  final Genero? genero;
  final Jogo? jogo;
  final JogoNatacao? jogoNatacao;

  // Campos culturais
  final String? tema;
  final CategoriaCultural? categoriaCultural;
  final List<String>? artistas;

  const SubEvento({
    required this.id,
    required this.categoriaId,
    this.categoria,
    required this.nome,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.local,
    required this.imagem,
    this.videoUrl,
    this.fotosUrl,
    this.placar,
    this.eventoPaiId,
    this.instituicaoId,
    // Novos campos
    this.tipo,
    this.categoriaEsportiva,
    this.genero,
    this.jogo,
    this.jogoNatacao,
    this.tema,
    this.categoriaCultural,
    this.artistas,
  });

  factory SubEvento.fromAPI(Map<String, dynamic> j) {
    String? _norm(String? v) {
      final s = (v ?? '').trim();
      return s.isEmpty ? null : s;
    }

    String? _idFromDynamic(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map<String, dynamic>) {
        return (raw['_id'] ?? raw['id'])?.toString();
      }
      return raw.toString();
    }

    final categoriaId = (j['categoriaId'] ?? '').toString();

    final rawJogo = j['jogo'];
    final rawJogoNatacao = j['jogoNatacao'];

    return SubEvento(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      categoriaId: categoriaId,
      categoria: _norm(j['categoria']?.toString()) ?? _norm(categoriaId),
      nome: (j['nome'] ?? '').toString(),
      descricao: (j['descricao'] ?? '').toString(),
      data: (j['data'] ?? '').toString(),
      hora: (j['hora'] ?? j['horario'] ?? '').toString(),
      local: (j['local'] ?? '').toString(),
      imagem: (j['imagem'] ?? j['fotoUrl'] ?? '').toString(),
      videoUrl: _norm(j['videoUrl']?.toString()),
      fotosUrl: _norm(j['fotosUrl']?.toString()),
      placar: _norm(j['placar']?.toString()),
      eventoPaiId: _idFromDynamic(j['eventoPaiId']),
      instituicaoId: _idFromDynamic(j['instituicaoId']),
      // Novos campos
      tipo: j['tipo'] != null ? _parseTipo(j['tipo']?.toString()) : null,
      categoriaEsportiva: j['categoriaEsportiva'] != null
          ? _parseCategoriEspotiva(j['categoriaEsportiva']?.toString())
          : null,
      genero: j['genero'] != null ? _parseGenero(j['genero']?.toString()) : null,
      jogo: rawJogo is Map<String, dynamic> ? Jogo.fromAPI(rawJogo) : null,
      jogoNatacao: rawJogoNatacao is Map<String, dynamic> ? JogoNatacao.fromAPI(rawJogoNatacao) : null,
      tema: _norm(j['tema']?.toString()),
      categoriaCultural: j['categoriaCultural'] != null
          ? _parseCategoriaCultural(j['categoriaCultural']?.toString())
          : null,
      artistas: _parseArtistas(j['artistas']),
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'categoriaId': categoriaId,
        'categoria': categoria,
        'nome': nome,
        'descricao': descricao,
        'data': data,
        'hora': hora,
        'local': local,
        'imagem': imagem,
        'videoUrl': videoUrl,
        'fotosUrl': fotosUrl,
        'placar': placar,
        'eventoPaiId': eventoPaiId,
        'instituicaoId': instituicaoId,
        // Novos campos
        'tipo': tipo?.name,
        'categoriaEsportiva': categoriaEsportiva?.name,
        'genero': genero?.name,
        'jogo': jogo?.toMap(),
        'jogoNatacao': jogoNatacao?.toMap(),
        'tema': tema,
        'categoriaCultural': categoriaCultural?.name,
        'artistas': artistas,
      };

  // Helpers estáticos para SubEvento
  static List<String>? _parseArtistas(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      final list = raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      return list.isEmpty ? null : list;
    }
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;
      final list = s.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return list.isEmpty ? null : list;
    }
    return null;
  }

  static Categoria? _parseTipo(String? value) {
    if (value == null) return null;
    try {
      return Categoria.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
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

// ---------------- EVENTO (SIMPLIFICADO) ----------------

class Evento {
  String? id;
  String nome;
  
  /// Agora pode ser: esportiva, cultural ou ambos
  Categoria categoria;
  
  String descricao;
  String data;
  String horario;
  String imagem;
  String local;

  /// DONO
  String? instituicaoId;
  Instituicao? instituicao;

  // links
  Uri? linkInscricao;
  Uri? linkTransmissao;
  Uri? linkResultados;
  Uri? linkFotos;

  // >>> subeventos (agora com os campos específicos)
  List<String> categoriasSubeventos;
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
    this.linkInscricao,
    this.linkTransmissao,
    this.linkResultados,
    this.linkFotos,
    List<String>? categoriasSubeventos,
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
      'linkInscricao': linkInscricao?.toString(),
      'linkTransmissao': linkTransmissao?.toString(),
      'linkResultados': linkResultados?.toString(),
      'linkFotos': linkFotos?.toString(),

      // >>> subeventos
      'categoriasSubeventos': categoriasSubeventos,
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

    Uri? _parseUri(dynamic raw) {
      final s = raw?.toString().trim();
      if (s == null || s.isEmpty) return null;
      return Uri.tryParse(s);
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
      linkInscricao: _parseUri(json['linkInscricao']),
      linkTransmissao: _parseUri(json['linkTransmissao']),
      linkResultados: _parseUri(json['linkResultados']),
      linkFotos: _parseUri(json['linkFotos']),

      // >>> subeventos
      categoriasSubeventos: (json['categoriasSubeventos'] is List)
          ? (json['categoriasSubeventos'] as List)
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList()
          : <String>[],
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
    Uri? linkInscricao,
    Uri? linkTransmissao,
    Uri? linkResultados,
    Uri? linkFotos,
    List<String>? categoriasSubeventos,
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
      linkInscricao: linkInscricao ?? this.linkInscricao,
      linkTransmissao: linkTransmissao ?? this.linkTransmissao,
      linkResultados: linkResultados ?? this.linkResultados,
      linkFotos: linkFotos ?? this.linkFotos,
      categoriasSubeventos: categoriasSubeventos ?? this.categoriasSubeventos,
      subeventos: subeventos ?? this.subeventos,
    );
  }

  // ---------------- HELPERS ESTÁTICOS ----------------

  static Categoria _parseCategoria(String? value) {
    switch (value) {
      case 'esportiva':
        return Categoria.esportiva;
      case 'cultural':
        return Categoria.cultural;
      case 'ambos':
        return Categoria.ambos;
      default:
        return Categoria.esportiva;
    }
  }
}
