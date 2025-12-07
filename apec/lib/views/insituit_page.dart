import 'package:flutter/material.dart';

class PerfilInstituicaoPage extends StatelessWidget {
  const PerfilInstituicaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final horizontalPadding =
        (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF4),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE5E5),
                Color(0xFFE5F7FF),
                Color(0xFFEDE5FF),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: _PerfilCard(horizontalPadding: horizontalPadding),
            ),
          ),
        ),
      ),
      // sua bottomNavigationBar/tabview entra aqui
    );
  }
}

class _PerfilCard extends StatelessWidget {
  final double horizontalPadding;
  const _PerfilCard({required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth - 2 * horizontalPadding).clamp(320.0, 500.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo circular
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.redAccent,
                width: 3,
              ),
              // substitua por Image.asset se tiver o logo real
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00A94F),
                  Color(0xFF00923F),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'IF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'IFCE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Campus Fortaleza',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Perfil destinado para eventos esportivos e culturais do '
            'instituto federal campus fortaleza',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 24),

          // Primeira seção de categoria
          const _SecaoCategoria(),

          const SizedBox(height: 24),

          // Segunda seção de categoria
          const _SecaoCategoria(),
        ],
      ),
    );
  }
}

class _SecaoCategoria extends StatelessWidget {
  const _SecaoCategoria();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth * 0.62).clamp(220.0, 280.0);
    final cardHeight =
        (cardWidth * 0.45).clamp(90.0, 120.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título "Nova categoria" + ícone editar
        Row(
          children: const [
            Text(
              'Nova categoria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 16,
              color: Color(0xFF263238),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Carrossel de cards
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _CategoriaCard(
                width: cardWidth,
                height: cardHeight,
                isPrincipal: index == 0,
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Indicador de página (3 bolinhas)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(isActive: true),
            const SizedBox(width: 4),
            _Dot(isActive: false),
            const SizedBox(width: 4),
            _Dot(isActive: false),
          ],
        ),
      ],
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final double width;
  final double height;
  final bool isPrincipal;

  const _CategoriaCard({
    required this.width,
    required this.height,
    required this.isPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0E0E0),
            Color(0xFFBDBDBD),
          ],
        ),
      ),
      child: isPrincipal
          ? Center(
              child: Container(
                width: height * 0.45,
                height: height * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade700,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: height * 0.32,
                  color: Colors.grey.shade700,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
