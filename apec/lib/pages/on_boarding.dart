import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:apec/pages/data/data.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Scaffold(
      backgroundColor: contentsList[currentIndex].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          contentsList[index].title,
                          style: const TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          contentsList[index].title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 24.0),
                        Expanded(
                          child: SvgPicture.asset(
                            contentsList[index].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: List.generate(
                            contentsList.length,
                            (index) => buildDot(index, context),
                          ),
                        ),
                        SizedBox(height: 10),
                        CupertinoButton(
                          child: Text(
                            "Pular",
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () {
                            //COLOCAR A FUNÇÂO QUE VAI PRA HOMEPAGE AQUI
                          },
                        ),
                      ],
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              value: porcentagem,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white38,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: contentsList[currentIndex].backgroundColor,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (currentIndex == contentsList.length - 1) {
                          //COLOCAR A FUNÇÂO QUE VAI PRA HOMEPAGE AQUI
                        }
                        _controller?.nextPage(
                          duration: Duration(milliseconds: 500),
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

  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 8,
      width: currentIndex == index ? 24 : 8,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
