import 'package:apec/pages/InstitPage.dart';
import 'package:apec/pages/starter_page.dart';
import 'package:flutter/material.dart';
import 'package:apec/pages/on_boarding.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/pages/tabview.dart';


void main() {
  runApp(const MyApp());
}


final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnBoarding()),
    GoRoute(
      path: '/starter_page',
      builder: (context, state) => const SegundaTela(),
    ),
    GoRoute(path: '/tabview', builder: (context, state) => const Tabview()),
    GoRoute(path: '/instituicao', builder: (context, state) => InstitPage()),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter APEC',
      routerConfig: _router,
    );
  }
}


