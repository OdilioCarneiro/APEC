import 'package:apec/pages/starter_page.dart';
import 'package:flutter/material.dart';
import 'on_boarding.dart';
import 'package:go_router/go_router.dart';
import 'tabview.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnBoarding(),
    ),
    GoRoute(
      path: '/starter_page',
      builder: (context, state) => const SegundaTela(),
    ),
    GoRoute(
      path: '/tabview',
      builder: (context, state) => const Tabview(),
    )
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
