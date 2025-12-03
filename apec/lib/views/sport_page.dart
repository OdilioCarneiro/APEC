import 'package:flutter/material.dart';

class SportPage extends StatelessWidget {
  const SportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Sport Page!'),
      ),
    );
  }
}