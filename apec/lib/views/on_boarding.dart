import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:apec/pages/data/data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  PageController? _controller;
  int currentIndex = 0;
  double percentage = 0.25;
  double porcentagem = 0.33;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final shortestSide = size.shortestSide;

    final bool isSmallPhone = shortestSide < 360;
    final double baseHorizontalPadding =
        (screenWidth * 0.06).clamp(16.0, 32.0); // 6% da largura
    final double titleFontSize = isSmallPhone ? 24 : 28;
    final double subtitleFontSize = isSmallPhone ? 16 : 18;
    final double dotHeight = isSmallPhone ? 6 : 8;
    final double dotWidthActive = isSmallPhone ? 18 : 24;
    final double dotWidthInactive = isSmallPhone ? 6 : 8;
    final double nextButtonSize =
        (screenWidth * 0.12).clamp(44.0, 56.0); // círculo do botão

    return Scaffold(
      backgroundColor: contentsList[currentIndex].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Parte superior: textos + imagem (PageView)
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _controller,
                itemCount: contentsList.length,
                onPageChanged: (int index) {
                  if (index >= currentIndex) {
                    setState(() {
                      currentIndex = index;
                      percentage += 0.25;
                      porcentagem += 0.34;
                    });
                  } else {
                    setState(() {
                      currentIndex = index;
                      percentage -= 0.25;
                      porcentagem -= 0.34;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  final content = contentsList[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: baseHorizontalPadding,
                      vertical: screenHeight * 0.04,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          content.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          // usando novamente title como texto de apoio, para não depender de subtitle
                          content.title,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Expanded(
                          child: SvgPicture.asset(
                            content.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Parte inferior: dots + "Pular" + botão circular
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: baseHorizontalPadding,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Esquerda: indicadores + Pular
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: List.generate(
                            contentsList.length,
                            (index) => buildDot(
                              index,
                              height: dotHeight,
                              activeWidth: dotWidthActive,
                              inactiveWidth: dotWidthInactive,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Text(
                            'Pular',
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () {
                            context.go('/starter_page');
                          },
                        ),
                      ],
                    ),

                    // Direita: botão próximo com progresso
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: nextButtonSize,
                            height: nextButtonSize,
                            child: CircularProgressIndicator(
                              value: porcentagem.clamp(0.0, 1.0),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white38,
                              strokeWidth: isSmallPhone ? 3 : 4,
                            ),
                          ),
                          CircleAvatar(
                            radius: nextButtonSize / 2.8,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: isSmallPhone ? 16 : 18,
                              color:
                                  contentsList[currentIndex].backgroundColor,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (currentIndex == contentsList.length - 1) {
                          context.go('/starter_page');
                          return;
                        }
                        _controller?.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(
    int index, {
    required double height,
    required double activeWidth,
    required double inactiveWidth,
  }) {
    final bool isActive = currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: height,
      width: isActive ? activeWidth : inactiveWidth,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
