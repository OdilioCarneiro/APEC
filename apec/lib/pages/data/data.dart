import 'package:flutter/material.dart';

class UnbordingContent {
  String image;
  String title;
  String description;
  Color backgroundColor;
  UnbordingContent({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}

List<UnbordingContent> contentsList = [
  UnbordingContent(
    image: 'assets/Making.svg',
    title: 'Discover New Features',
    description: 'Explore the app to find out more.',
    backgroundColor: const Color(0xFFF5E15F),
  ),
  UnbordingContent(
    image: 'assets/Creative.svg',
    title: 'Get Started Now',
    description: 'Sign up and enjoy the experience.',
    backgroundColor: Color(0xFF59B0E3),
  ),
  UnbordingContent(
    image: 'assets/basketball.svg',
    title: 'Get Started Now',
    description: 'Sign up and enjoy the experience.',
    backgroundColor: const Color(0xFFFA4050),
  ),
];



class Instituicao {
  String nome;
  String descricao;
  String? imagem;
  Instituicao({
    required this.nome,
    required this.descricao,
    this.imagem,
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