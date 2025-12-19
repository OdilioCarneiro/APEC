import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 

class CadasInstPage extends StatefulWidget {
  const CadasInstPage({super.key});

  @override
  State<CadasInstPage> createState() => CadastroInstPage();
}

class CadastroInstPage extends State<CadasInstPage> {
  // Chave global para o formulário (útil para validação)
  final _formKey = GlobalKey<FormState>();

  // --- LÓGICA DE SELEÇÃO DE IMAGEM ---
  File? _imageFile; // Variável para armazenar o arquivo de imagem selecionado
  final _picker = ImagePicker(); // Objeto para selecionar a imagem

  // Função para selecionar a imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Atualiza o estado da tela com a nova imagem
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  // ------------------------------------


  // Função auxiliar para padronizar o visual dos campos de texto
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      // Borda padrão
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Borda quando o campo está habilitado
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Borda quando o campo está em foco
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        // Cor corrigida: const Color.fromARGB(255, 41, 182, 246) é uma aproximação de lightBlue.shade400
        borderSide: const BorderSide(color: Color.fromARGB(255, 41, 182, 246), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  // Widget de Avatar de Perfil (MODIFICADO)
  Widget _buildProfileAvatar() {
    final List<Color> gradientColors = [
      const Color.fromARGB(255, 239, 171, 166),
      const Color.fromARGB(255, 222, 146, 172),
      const Color.fromARGB(255, 220, 137, 234),
      const Color.fromARGB(255, 117, 165, 204),
      const Color.fromARGB(255, 118, 215, 228),
      const Color.fromARGB(255, 160, 229, 162),
      const Color.fromARGB(255, 249, 241, 172),
      const Color.fromARGB(255, 241, 212, 169),
    ];

    return Center(
      child: Stack(
        children: [
          // 1. O Anel Colorido e o Avatar principal
          Container(
            padding: const EdgeInsets.all(4.0), 
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: gradientColors,
                startAngle: 0.0,
                endAngle: 3.14 * 2, 
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56, 
                backgroundColor: const Color(0xFFE0E0E0), 
                // Exibe a imagem selecionada, se houver
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                // Exibe o ícone de pessoa APENAS se não houver imagem
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 80, color: Colors.white)
                    : null,
              ),
            ),
          ),
          
          // 2. O Ícone/Botão de Câmera para Selecionar a Foto
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell( // Faz com que o círculo seja clicável
              onTap: _pickImage, // Chama a função para selecionar a imagem
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade400, // Cor do botão
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3), // Borda branca
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para os campos de texto (inalterado)
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Nome da Instituição
        TextFormField(
          decoration: _inputDecoration('Digite o nome da instituição'),
        ),
        const SizedBox(height: 8),

        // Texto Opcional
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            '*Opcional',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),

        // 2. Campus/Região (Opcional)
        TextFormField(
          decoration: _inputDecoration('Digite o campus/região da sua instituição'),
        ),
        const SizedBox(height: 16),

        // 3. Biografia (Múltiplas Linhas)
        TextFormField(
          maxLines: 4,
          decoration: _inputDecoration('Escreva uma breve biografia sobre a instituição'),
        ),
        const SizedBox(height: 16),

        // 4. Email da Instituição
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Digite o email da instituição'),
        ),
        const SizedBox(height: 16),

        // 5. Senha
        TextFormField(
          obscureText: true,
          decoration: _inputDecoration('Digite a senha'),
        ),
        const SizedBox(height: 16),

        // 6. Confirmar Senha
        TextFormField(
          obscureText: true,
          decoration: _inputDecoration('Confirmar senha'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Widget para o botão de cadastro (inalterado)
  Widget _buildCadastrarButton() {
    return ElevatedButton(
      onPressed: () {
        // Lógica de cadastro: if (_formKey.currentState!.validate()) { ... }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastrando... Imagem selecionada: ${_imageFile != null ? "Sim" : "Não"}')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade400, // Cor de fundo
        foregroundColor: Colors.white, // Cor do texto
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Borda arredondada
        ),
        elevation: 4,
      ),
      child: const Text(
        'Cadastrar',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, 
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 40.0), 
                          child: SizedBox.shrink(),
                        ),
                        
                        _buildProfileAvatar(),
                        const SizedBox(height: 40),
                        
                        _buildFormFields(),
                        
                        const Spacer(), 

                        _buildCadastrarButton(),
                        
                        const Padding(
                          padding: EdgeInsets.only(bottom: 40.0), 
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}