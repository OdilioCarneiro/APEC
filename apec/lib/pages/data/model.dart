

class Instituicao {
  String? nome;
  String? descricao;
  String imagem;
  Instituicao({
    this.nome,
    this.descricao,
    required this.imagem,
  });

  // Função toMap para MongoDB
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
    };
  }
}


enum Genero {
  masculino,
  feminino,
  outros
}

enum CategoriEspotiva {
  futebol,
  basquete,
  voleibol,
  corrida,
  ciclismo,
  carimba,
  natacao,
  artesMarciais,
  ginastica,
  tenis
}

enum Categoria {
   esportiva, 
   cultural
}

class Evento {
  String nome;
  Categoria categoria;
  String descricao;
  String data;
  String horario;
  String imagem;
  String  local;

  //campo só para eventos esportivos
  CategoriEspotiva? categoriaEsportiva;
  Genero? genero;
  Jogo? jogo;
  JogoNatacao? jogoNatacao;

  //campo só para eventos culturais
  String? tema;
  CategoriaCultural? categoriaCultural;
  List<String>? artistas;

  //campo para ambos os tipos de evento
  Uri? linkInscricao;
  Uri? linkTransmissao;
  Uri? linkResultados;
  Uri? linkFotos;


  Evento({
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.data,
    required this.local,
    required this.imagem,
    required this.horario,
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
  });

  Map<String, dynamic> toMap(){
    return{
      'nome': nome,
      'categoria': categoria.name,
      'descricao': descricao,
      'data': data,
      'horario': horario,
      'imagem': imagem,
      'local': local,
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
    };
  }

  // Factory para criar Evento a partir da resposta da API
  factory Evento.fromAPI(Map<String, dynamic> json) {
    return Evento(
      nome: json['nome'] ?? '',
      categoria: _parseCategoria(json['categoria']),
      descricao: json['descricao'] ?? '',
      data: json['data'] ?? '',
      horario: json['horario'] ?? '',
      local: json['local'] ?? '',
      imagem: json['imagem'] ?? '',
      categoriaEsportiva: json['categoriaEsportiva'] != null 
          ? _parseCategoriEsportiva(json['categoriaEsportiva'])
          : null,
      genero: json['genero'] != null 
          ? _parseGenero(json['genero'])
          : null,
      tema: json['tema'],
      categoriaCultural: json['categoriaCultural'] != null
          ? _parseCategoriaCultural(json['categoriaCultural'])
          : null,
      artistas: json['artistas'] != null 
          ? List<String>.from(json['artistas'])
          : null,
    );
  }

  // Helper methods para converter strings em enums
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

  static CategoriEspotiva? _parseCategoriEsportiva(String? value) {
    if (value == null) return null;
    try {
      return CategoriEspotiva.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  static Genero? _parseGenero(String? value) {
    if (value == null) return null;
    try {
      return Genero.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  static CategoriaCultural? _parseCategoriaCultural(String? value) {
    if (value == null) return null;
    try {
      return CategoriaCultural.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

//classe para eventos esportivos
class Jogo{
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

  Map<String, dynamic> toMap(){
    return{
      'timeA': timeA,
      'timeB': timeB,
      'placarA': placarA,
      'placarB': placarB,
      'data': data,
      'local': local,
    };
  }
}
enum ModalidadeNatacao {
  crawl,
  costas,
  peito,
  borboleta,
  medley
}

class JogoNatacao{
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
// final da classe para eventos esportivos

//classe para eventos culturais
enum CategoriaCultural {
  musica,
  teatro,
  danca,
  exposicao,
  cinema,
  literatura
}
//final da classe para eventos culturais