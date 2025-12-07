import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  // Atualize isso com a URL do seu backend quando estiver rodando
  static const String baseUrl = 'https://apec-1-25ad.onrender.com/api';

  // Para testar em um dispositivo físico, use o IP da máquina em vez de localhost
  // static const String baseUrl = 'http://SEU_IP:3000/api';

  /// Listar todos os eventos
  static Future<List<dynamic>> listarEventos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/eventos'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao listar eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Obter um evento específico por ID
  static Future<Map<String, dynamic>> obterEvento(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/eventos/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Evento não encontrado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Criar evento de forma inteligente (imagem opcional)
  static Future<Map<String, dynamic>> criarEventoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
  }) async {
    final uri = Uri.parse('$baseUrl/eventos');

    // CENÁRIO 1: Sem imagem -> Envia JSON normal
    if (imagem == null) {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dados),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao criar evento (JSON): ${response.statusCode} - ${response.body}');
      }
    }

    // CENÁRIO 2: Com imagem -> Envia Multipart
    final request = http.MultipartRequest('POST', uri);

    // 1. Adiciona arquivo PRIMEIRO
    final stream = http.ByteStream(imagem.openRead());
    final length = await imagem.length();
    final multipartFile = http.MultipartFile(
      'imagem',
      stream,
      length,
      filename: imagem.path.split('/').last,
    );
    request.files.add(multipartFile);

    // 2. Adiciona campos DEPOIS (converte para String)
    dados.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao criar evento (Multipart): ${response.statusCode} - ${response.body}');
    }
  }

  /// Atualizar um evento
  static Future<Map<String, dynamic>> atualizarEvento(
    String id,
    Map<String, dynamic> evento,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/eventos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(evento),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao atualizar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Deletar um evento
  static Future<void> deletarEvento(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/eventos/$id'));

      if (response.statusCode != 200) {
        throw Exception('Erro ao deletar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Listar eventos por categoria
  static Future<List<dynamic>> listarEventosPorCategoria(String categoria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/eventos/categoria/$categoria'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao listar eventos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Verificar se a API está disponível
  static Future<bool> verificarSaude() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api', '')}/api/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
