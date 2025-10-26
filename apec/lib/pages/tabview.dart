import 'package:apec/pages/Cultura_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:apec/pages/HomePage.dart';
import 'package:apec/pages/Sport_page.dart';
import 'package:apec/pages/Instit_page.dart';

class Tabview extends StatefulWidget {
  const Tabview({super.key});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    Homepage(),
    CulturaPage(),
    SportPage(),
    InstitPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        
        child: Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
            items: <Widget>[
              Icon(
                _currentIndex == 0 ? Icons.stars : Icons.stars_outlined,
                size: 30,
              ),
              Icon(
                _currentIndex == 1 ? Icons.sports_volleyball : Icons.sports_volleyball_outlined,
                size: 30,
              ),
              Icon(
                _currentIndex == 2 ? Icons.theater_comedy : Icons.theater_comedy_outlined,
                size: 30,
              ),
              Icon(
                _currentIndex == 3 ? Icons.person : Icons.person_outlined,
                size: 30,
              ),
            ],
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
          ),
        ),
      ),
    );
  }
}