import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_exception.dart';
import 'http_exception_handler.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 60),
  })  : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client(),
        _handler = HttpExceptionHandler(timeout: timeout);

  final String baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _http;
  final HttpExceptionHandler _handler;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _headers({bool conJson = true}) async {
    final token = await _tokenStorage.leer();
    return <String, String>{
      'Accept': 'application/json',
      if (conJson) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodificar(http.Response response) {
    Map<String, dynamic>? cuerpo;
    final texto = utf8.decode(response.bodyBytes, allowMalformed: true);

    if (texto.trim().isNotEmpty) {
      try {
        final decodificado = jsonDecode(texto);
        if (decodificado is Map) {
          cuerpo = Map<String, dynamic>.from(decodificado);
        }
      } catch (_) {
        cuerpo = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return cuerpo ?? <String, dynamic>{};
    }

    final error = cuerpo?['error'];
    final detalle = error is Map ? Map<String, dynamic>.from(error) : null;
    final mensaje = detalle?['message']?.toString() ??
        'El servidor respondió con un error (${response.statusCode}).';

    throw ApiException(
      mensaje,
      code: detalle?['code']?.toString() ?? 'ERROR_API',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final respuesta = await _handler.ejecutar(() async {
      return _http.get(_uri(path), headers: await _headers());
    });
    return _decodificar(respuesta);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final respuesta = await _handler.ejecutar(() async {
      return _http.post(
        _uri(path),
        headers: await _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      );
    });
    return _decodificar(respuesta);
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final respuesta = await _handler.ejecutar(() async {
      return _http.delete(_uri(path), headers: await _headers());
    });
    return _decodificar(respuesta);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String> fields = const <String, String>{},
    required String filePath,
    String fileField = 'imagen',
    String? mimeType,
  }) {
    return _handler.ejecutar(
      () async {
        final peticion = http.MultipartRequest('POST', _uri(path));
        peticion.headers.addAll(await _headers(conJson: false));
        peticion.fields.addAll(fields);
        peticion.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            filePath,
            contentType: _mediaType(filePath, mimeType),
          ),
        );

        final streamed = await peticion.send();
        final respuesta = await http.Response.fromStream(streamed);
        return _decodificar(respuesta);
      },
      timeoutMessage:
          'El análisis tardó demasiado. Intenta con una foto más ligera.',
      networkMessage: 'No pudimos enviar la foto al servidor de EduGuía. '
          'Revisa tu internet e intenta de nuevo.',
    );
  }

  MediaType _mediaType(String filePath, String? mimeType) {
    if (mimeType != null && mimeType.isNotEmpty) {
      final partes = mimeType.split('/');
      if (partes.length == 2) {
        return MediaType(partes[0], partes[1]);
      }
    }

    final extension = filePath.toLowerCase().split('.').last;
    return switch (extension) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  Future<void> guardarToken(String token) => _tokenStorage.guardar(token);

  Future<void> cerrarSesion() => _tokenStorage.borrar();

  Future<bool> tieneToken() async {
    final token = await _tokenStorage.leer();
    return token != null && token.isNotEmpty;
  }
}
