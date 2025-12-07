import 'package:apec/views/cultura_page.dart';
import 'package:apec/views/login.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:apec/views/home_page.dart';
import 'package:apec/views/sport_page.dart';



class Tabview extends StatefulWidget {
  const Tabview({super.key});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  int _currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    SportPage(),
    CulturaPage(),
    InstitPage()
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
          extendBody: true,
          bottomNavigationBar: CurvedNavigationBar(
           color: const Color.fromARGB(246, 246, 246, 246),                 // cor da “pista” curvada
            buttonBackgroundColor: const Color.fromARGB(246, 246, 246, 246), // bolha do item ativo
            backgroundColor: Colors.transparent, // deixa ver o fundo do body
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 400),
            height: 60,
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