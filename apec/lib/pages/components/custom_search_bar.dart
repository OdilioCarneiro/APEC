import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Search', // Texto padrão da Home
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container para manter a borda cinza e o fundo branco igual ao da Home
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33263238), width: 1),
      ),
      // O segredo: Usar o componente nativo do iOS
      child: CupertinoSearchTextField(
        controller: controller,
        onSubmitted: onSubmitted,
        placeholder: hintText,
        backgroundColor: Colors.transparent, // Transparente para usar o branco do container
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
