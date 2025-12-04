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

class CardContent {
  String image;
  String title;
  Color backgroundColor;
  CardContent({
    required this.image,
    required this.title,
    required this.backgroundColor,
  });
}

List<CardContent> cardContent = [

CardContent(
  image: 'assets/dance.svg',
  title: 'Dança',
  backgroundColor: const Color.fromARGB(255, 19, 86, 140),
),

CardContent(
  image: 'assets/music.svg',
  title: 'Música',
  backgroundColor: const Color.fromARGB(255, 140, 19, 19),
),

CardContent(
  image: 'assets/paint.svg',
  title: 'Exposições',
  backgroundColor: const Color.fromARGB(255, 136, 140, 19),
),

CardContent(
  image: 'assets/theater.svg',
  title: 'Cinema/Teatro',
  backgroundColor: const Color.fromARGB(255, 140, 19, 19),
),

CardContent(
  image: 'assets/books.svg',
  title: 'Literatura',
  backgroundColor: const Color.fromARGB(255, 19, 86, 140),
)
];


class CardContentsport {
  String image;
  String title;
  Color backgroundColor;
  CardContentsport({
    required this.image,
    required this.title,
    required this.backgroundColor,
  });
}

List<CardContentsport> cardContentsport = [

CardContentsport(
  image: 'assets/nado.svg',
  title: 'Natação',
  backgroundColor: const Color.fromARGB(255, 19, 86, 140),
),

CardContentsport(
  image: 'assets/basket.svg',
  title: 'Basquete',
  backgroundColor: const Color.fromARGB(255, 140, 19, 19),
),

CardContentsport(
  image: 'assets/volley.svg',
  title: 'Vôlei',
  backgroundColor: const Color.fromARGB(255, 136, 140, 19),
),

CardContentsport(
  image: 'assets/handbol.svg',
  title: 'Handeboll',
  backgroundColor: const Color.fromARGB(255, 140, 19, 19),
),
];



