import 'package:apec/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// MODELS
import 'package:apec/pages/data/model.dart'; 

// VIEWS/PAGES
import 'package:apec/views/on_boarding.dart';
import 'package:apec/views/starter_page.dart';
import 'package:apec/views/cadastro.dart';
import 'package:apec/views/event_page.dart';

import 'package:apec/views/home_page.dart';
import 'package:apec/views/sport_page.dart';
import 'package:apec/views/cultura_page.dart';
import 'package:apec/views/insituit_page.dart';
import 'package:apec/pages/CadasInstPage.dart'; 

import 'package:apec/pages/components/tabview.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
  
}

final _rootKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootKey,

  initialLocation: '/',

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
      redirect: (context, state) => '/home',
    ),


    ShellRoute(
      builder: (context, state, child) => Tabview(child: child),
      routes: [

        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/sport',
          builder: (context, state) => const SportPage(),
        ),
        GoRoute(
          path: '/cultura',
          builder: (context, state) => const CulturaPage(),
        ),

        GoRoute(
          path: '/perfil_instituicao',
          builder: (context, state) => const PerfilInstituicaoPage(),
        ),

         GoRoute(
            path: '/cadastro_evento',
            builder: (context, state) => const Cadastro(),
            ),

        GoRoute(
          path: '/login',
          builder: (context, state) => const InstitPage(),
          routes: [
            GoRoute(
              path: '/perfil_instituicao',
              builder: (context, state) => const PerfilInstituicaoPage(),
            ),
           
            GoRoute(
              path: '/cadastro_instituicao',
              builder: (context, state) => const CadasInstPage(),
            ),
          ],
        ),

        GoRoute(
          path: '/evento',
          builder: (context, state) {
            final evento = state.extra as Evento;
            return EventPage(evento: evento);
          },
        ),
      ],
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
