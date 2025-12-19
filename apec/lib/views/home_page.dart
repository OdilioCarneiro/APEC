import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart';

const titleColor = Color(0xFF263238);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _eventosAPI;

  @override
  void initState() {
    super.initState();
    _eventosAPI = ApiService.listarEventos();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // padding responsivo da página
    final horizontalPadding = screenWidth * 0.05; // 5% de cada lado, com clamp
    final clampedPadding =
        horizontalPadding.clamp(16.0, 32.0); // mínimo 16, máximo 32

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: clampedPadding,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de busca
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0x33263238),
                    width: 1,
                  ),
                ),
                child: const CupertinoSearchTextField(
                  placeholder: 'Search',
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Eventos culturais',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Lista de eventos
              FutureBuilder<List<dynamic>>(
                future: _eventosAPI,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar eventos:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _eventosAPI = ApiService.listarEventos();
                              }),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final eventos = snapshot.data ?? [];

                  if (eventos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_note,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('Nenhum evento encontrado'),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  }

                  // Grade responsiva de cards usando LayoutBuilder + Wrap
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;

                        // largura mínima desejada por card
                        const minCardWidth = 260.0;
                        const maxCardWidth = 340.0;

                        // número de colunas possível
                        int columns =
                            (maxWidth / minCardWidth).floor().clamp(1, 4);
                        final effectiveCardWidth =
                            (maxWidth - (columns - 1) * 18) / columns;
                        final cardWidth =
                            effectiveCardWidth.clamp(minCardWidth, maxCardWidth);

                        return Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: eventos.map((e) {
                            final evento = Evento.fromAPI(e);
                            return SizedBox(
                              width: cardWidth,
                              child: EventCardComponent(evento: evento),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
