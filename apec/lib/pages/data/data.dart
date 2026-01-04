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
    title: 'Cultura e esporte no mesmo app',
    description: 'Encontre shows, exposições, oficinas e competições em poucos segundos.',
    backgroundColor: const Color(0xFFF5E15F),
  ),
  UnbordingContent(
    image: 'assets/Creative.svg',
    title: 'Todos os detalhes em um toque',
    description: 'cesse data, local e informações do evento para se planejar com facilidade',
    backgroundColor: Color(0xFF59B0E3),
  ),
  UnbordingContent(
    image: 'assets/basketball.svg',
    title: 'Vários eventos em um só lugar',
    description: 'Descubra eventos culturais e esportivos de instituições por todo o país',
    backgroundColor: const Color(0xFFFA4050),
  ),
];

class CardContent {
  String image;
  String title;
  String key; 
  Color backgroundColor;

  CardContent({
    required this.image,
    required this.title,
    required this.key,
    required this.backgroundColor,
  });
}

List<CardContent> cardContent = [
  CardContent(
    image: 'assets/dance.svg',
    title: 'Dança',
    key: 'danca',
    backgroundColor: const Color.fromARGB(255, 19, 86, 140),
  ),
  CardContent(
    image: 'assets/music.svg',
    title: 'Música',
    key: 'musica',
    backgroundColor: const Color.fromARGB(255, 140, 19, 19),
  ),
  CardContent(
    image: 'assets/paint.svg',
    title: 'Exposições',
    key: 'exposicao',
    backgroundColor: const Color.fromARGB(255, 136, 140, 19),
  ),
  CardContent(
    image: 'assets/books.svg',
    title: 'Literatura',
    key: 'literatura',
    backgroundColor: const Color.fromARGB(255, 19, 86, 140),
  ),
  CardContent(
    image: 'assets/theater.svg',
    title: 'Cinema/Teatro',
    key: 'cinema',
    backgroundColor: const Color.fromARGB(255, 140, 19, 19),
  ),
];



class CardContentsport {
  String image;
  String title;
  String key;
  Color backgroundColor;
  CardContentsport({
    required this.image,
    required this.title,
    required this.key,
    required this.backgroundColor,
  });
}

List<CardContentsport> cardContentsport = [
  CardContentsport(
    image: 'assets/nado.svg',
    title: 'Natação',
    key: 'natacao',
    backgroundColor: const Color.fromARGB(255, 19, 86, 140),
  ),

  CardContentsport(
    image: 'assets/basketball.svg',
    title: 'Basquete',
    key: 'basquete',
    backgroundColor: const Color.fromARGB(255, 140, 19, 19),
  ),

  CardContentsport(
    image: 'assets/volley.svg',
    title: 'Vôlei',
    key: 'voleibol', // enum: voleibol
    backgroundColor: const Color.fromARGB(255, 136, 140, 19),
  ),

  CardContentsport(
    image: 'assets/futsal.svg',
    title: 'Futebol',
    key: 'futebol', // enum: futebol
    backgroundColor: const Color.fromARGB(255, 19, 86, 140),
  ),

  CardContentsport(
    image: 'assets/carimba.svg',
    title: 'Queimada',
    key: 'carimba', // enum: carimba
    backgroundColor: const Color.fromARGB(255, 136, 140, 19),
  ),

  CardContentsport(
    image: 'assets/corrida.svg',
    title: 'Corridas',
    key: 'corrida', // enum: corrida
    backgroundColor: const Color.fromARGB(255, 140, 19, 19),
  ),

  CardContentsport(
    image: 'assets/lutas.svg',
    title: 'Lutas',
    key: 'artesMarciais', // enum: artesMarciais
    backgroundColor: const Color.fromARGB(255, 136, 140, 19),
  ),

  CardContentsport(
    image: 'assets/handbol.svg',
    title: 'Handeboll',
    key: 'handeboll', // enum: handeboll (sim, com esse nome)
    backgroundColor: const Color.fromARGB(255, 140, 19, 19),
  ),

  
];




