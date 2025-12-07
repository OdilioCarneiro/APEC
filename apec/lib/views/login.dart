import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';


class InstitPage extends StatelessWidget {
  const InstitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8E9D5),
              Color(0xFFE8D5F8),
              Color(0xFFD5F8F6),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LOGO
                          SvgPicture.asset(
                            'assets/Icon.svg',
                            height: 150,
                          ),
                          const SizedBox(height: 60),

                          // EMAIL
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Digite o email da instituição",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // SENHA
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Digite a senha",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // BOTÃO LOGIN
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                context.go('/cadastro');
                              },
                              child: const Text("Login",
                                  style: TextStyle(fontSize: 18, color: Colors.white)
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ESQUECEU A SENHA
                          const Text(
                            "Esqueceu a senha?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 25),

                          // BOTÃO CADASTRAR
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.lightBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Cadastrar", 
                              style: TextStyle(
                               fontSize: 18,
                               color:  Colors.lightBlue)
                               ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}