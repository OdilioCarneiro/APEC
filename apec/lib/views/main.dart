import 'package:apec/pages/data/model.dart';
import 'package:apec/views/cadastro.dart';
import 'package:apec/views/event_page.dart';
import 'package:apec/views/starter_page.dart';
import 'package:flutter/material.dart';
import 'on_boarding.dart';
import 'package:go_router/go_router.dart';
import '../pages/components/tabview.dart';
import 'package:flutter/services.dart';
import 'package:apec/views/insituit_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
  ]);
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
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const Cadastro(),
    ),
     GoRoute(
      path: '/perfil_instituicao',
      builder: (context, state) => const PerfilInstituicaoPage(),
    ),
    GoRoute(
      path: '/evento',
      builder: (context, state) {
      final evento = state.extra as Evento; // importa Evento do seu model
      return EventPage(evento: evento);
  },
    ),
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
