import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/pages/components/card.dart';
import 'cadastro.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Evento> _eventos = [];

  Future<void> _abrirCadastro() async {
    final Evento? novo = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroEventoScreen()),
    );
    if (novo != null) {
      setState(() => _eventos.add(novo)); 
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          children: _eventos
              .map((e) => EventCardComponent(evento: e))
              .toList(),
        ),
      ),
    );
  }
}

