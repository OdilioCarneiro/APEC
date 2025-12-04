import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/views/cadastro.dart'; 
import 'package:apec/pages/components/card.dart';

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

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroEventoScreen()),
    );
    // Atualizar lista de eventos após cadastro
    if (resultado != null) {
      setState(() {
        _eventosAPI = ApiService.listarEventos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _eventosAPI,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar eventos:\n${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _eventosAPI = ApiService.listarEventos();
                    }),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum evento encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _abrirCadastro,
                    child: const Text('Criar primeiro evento'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              children: eventos.map((e) {
                final evento = Evento.fromAPI(e);
                 return EventCardComponent(evento: evento);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

