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

import 'package:apec/views/instituicao/instit_public_page.dart';
import 'package:apec/views/instituicao/editar_evento_page.dart';
import 'package:apec/views/instituicao/event_page_instit.dart';
import 'package:apec/views/home_page.dart';
import 'package:apec/views/sport_page.dart';
import 'package:apec/views/cultura_page.dart';
import 'package:apec/views/instituicao/insituit_page.dart';
import 'package:apec/views/instituicao/CadasInstPage.dart';
import 'package:apec/views/cadastro_subevento_page.dart';
import 'package:apec/views/instituicao/edit_inst_page.dart';
import 'package:apec/views/editar_subevento_page.dart';

import 'package:apec/pages/components/tabview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

// ====== TEMA GLOBAL (AZUL) ======
const Color kBrandBlue = Color.fromARGB(255, 66, 186, 255);

ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 32, 173, 255),
    brightness: brightness,
  ); // [web:327]


  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme, // muda a “cor padrão” do app inteiro [web:340]

    // Textfield
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionHandleColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.25),
    ),

    // loading global
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
    ),

    // DatePicker
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: scheme.primary,
      headerForegroundColor: scheme.onPrimary,
      todayForegroundColor: WidgetStatePropertyAll(scheme.primary),
    ),

    // TimePicker
    timePickerTheme: TimePickerThemeData(
      dialHandColor: scheme.primary,
      dialBackgroundColor: scheme.surfaceContainerHighest,
      hourMinuteColor: scheme.primary.withValues(alpha: 0.12),
      hourMinuteTextColor: scheme.onSurface,
      dayPeriodColor: scheme.primary.withValues(alpha: 0.12),
      dayPeriodTextColor: scheme.primary,
      entryModeIconColor: scheme.primary,
    ),
  );
}

// ====== ROUTER ======
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

    // Shell com Tabview
    ShellRoute(
      builder: (context, state, child) => Tabview(child: child),
      routes: [
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
            GoRoute(
              path: 'edit_inst_page',
              builder: (context, state) {
                final initial = state.extra as Map<String, dynamic>?;
                return EditarInstPage(initial: initial);
              },
            ),
            GoRoute(
              path: 'perfil_instituicao',
              builder: (context, state) => const PerfilInstituicaoPage(),
            ),
            GoRoute(
              path: 'cadastro_evento',
              builder: (context, state) => const Cadastro(),
            ),
            GoRoute(
              path: 'editar_subevento',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return EditarSubEventoPage(
                  eventoPai: extra['eventoPai'] as Evento,
                  subevento: extra['subevento'] as SubEvento,
                  categorias: (extra['categorias'] as List).cast<String>(),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/instituicao',
          builder: (context, state) {
            final inst = state.extra as Instituicao; 
            return InstituicaoPublicaPage(instituicao: inst);
          },
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

            final Evento evento = rawEvento is Evento ? rawEvento : Evento.fromAPI(rawEvento as Map<String, dynamic>);

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

      // TEMA GLOBAL APLICADO A TODAS AS PÁGINAS
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark), // pode remover se não usar
      themeMode: ThemeMode.light, // troque pra ThemeMode.system se quiser
    );
  }
}
