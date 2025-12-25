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

import 'package:apec/views/instituicao/editar_evento_page.dart';
import 'package:apec/views/instituicao/event_page_instit.dart';
import 'package:apec/views/home_page.dart';
import 'package:apec/views/sport_page.dart';
import 'package:apec/views/cultura_page.dart';
import 'package:apec/views/instituicao/insituit_page.dart';
import 'package:apec/views/instituicao/CadasInstPage.dart';
import 'package:apec/views/cadastro_subevento_page.dart';
import 'package:apec/views/instituicao/edit_inst_page.dart';

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

    // LOGIN FORA DO SHELL (para não aparecer Tabview no login)
    GoRoute(
      path: '/login',
      builder: (context, state) => const InstitPage(),
      routes: [
        GoRoute(
          path: 'editar_evento',
          builder: (context, state) {
            final evento = state.extra as Evento;
            return EditarEventoPage(evento: evento);
          },
        ),
        GoRoute(
          path: 'cadastro_instituicao',
          builder: (context, state) => const CadasInstPage(),
        ),

        // CORRETO: rota filha sem começar com "/"
        GoRoute(
          path: 'edit_inst_page',
          builder: (context, state) {
            final initial = state.extra as Map<String, dynamic>?;
            return EditarInstPage(initial: initial);
          },
        ),
      ],
    ),

    // Shell com Tabview
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

        // DEIXE PERFIL SÓ AQUI (removido duplicado dentro de /login)
        GoRoute(
          path: '/perfil_instituicao',
          builder: (context, state) => const PerfilInstituicaoPage(),
        ),

        GoRoute(
          path: '/cadastro_evento',
          builder: (context, state) => const Cadastro(),
        ),
        GoRoute(
          path: '/subevento',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return CadastroSubEvento(
              eventoPai: extra['eventoPai'] as Evento,
              categoriaInicial: (extra['categoria'] ?? '').toString(),
              categorias: (extra['categorias'] as List?)?.cast<String>() ?? const ['Subeventos'],
            );
          },
        ),

        GoRoute(
          path: '/evento',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final rawEvento = extra['evento'];
            final bool isDono = (extra['isDono'] as bool?) ?? false;

            final Evento evento = rawEvento is Evento
                ? rawEvento
                : Evento.fromAPI(rawEvento as Map<String, dynamic>);

            if (isDono) return EventosPageInstit(evento: evento);
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
