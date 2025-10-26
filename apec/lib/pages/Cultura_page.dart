import 'package:flutter/material.dart';

class CulturaPage extends StatelessWidget {
  const CulturaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultura Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Cultura Page!'),
      ),
    );
  }
}