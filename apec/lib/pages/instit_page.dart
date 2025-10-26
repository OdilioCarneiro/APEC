import 'package:flutter/material.dart';

class InstitPage extends StatelessWidget {
  const InstitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institucion Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Institucion Page!'),
      ),
    );
  }
}