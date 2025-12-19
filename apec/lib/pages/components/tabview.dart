import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class Tabview extends StatefulWidget {
  final Widget child;
  const Tabview({super.key, required this.child});

  @override
  State<Tabview> createState() => _TabviewState();
}

class _TabviewState extends State<Tabview> {
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/sport')) return 1;
    if (loc.startsWith('/cultura')) return 2;
    if (loc.startsWith('/login')) return 3;
    return 0;
  }

  void _goTab(int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/sport'); break;
      case 2: context.go('/cultura'); break;
      case 3: context.go('/login'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color.fromARGB(246, 246, 246, 246),
        buttonBackgroundColor: const Color.fromARGB(246, 246, 246, 246),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        height: 60,
        index: currentIndex,
        items: <Widget>[
          Icon(currentIndex == 0 ? Icons.stars : Icons.stars_outlined, size: 30),
          Icon(currentIndex == 1 ? Icons.sports_volleyball : Icons.sports_volleyball_outlined, size: 30),
          Icon(currentIndex == 2 ? Icons.theater_comedy : Icons.theater_comedy_outlined, size: 30),
          Icon(currentIndex == 3 ? Icons.person : Icons.person_outlined, size: 30),
        ],
        onTap: _goTab,
      ),
    );
  }
}
