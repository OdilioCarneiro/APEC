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