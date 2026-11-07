import 'dart:async' as async;

import 'package:http/http.dart' as http;

import '../../core/errors/domain_exception.dart';
import '../../core/errors/network_exceptions.dart';

/// Traduce errores crudos de `http`/`dart:async` a excepciones de dominio
/// entendibles por la capa de presentación.
class HttpExceptionHandler {
  const HttpExceptionHandler({
    this.timeout = const Duration(seconds: 60),
    this.timeoutMessage,
    this.networkMessage,
  });

  final Duration timeout;
  final String? timeoutMessage;
  final String? networkMessage;

  Future<T> ejecutar<T>(
    Future<T> Function() accion, {
    String? timeoutMessage,
    String? networkMessage,
  }) async {
    final mensajeTimeout = timeoutMessage ?? this.timeoutMessage;
    final mensajeRed = networkMessage ?? this.networkMessage;

    try {
      return await accion().timeout(timeout);
    } on async.TimeoutException {
      throw TimeoutException(
        mensajeTimeout ??
            'La IA tardó demasiado en responder. '
                'Intenta con una foto más ligera.',
      );
    } on http.ClientException {
      throw NetworkException(
        mensajeRed ??
            'No pudimos conectar con el servidor de EduGuía. '
                'Revisa tu internet e intenta de nuevo.',
      );
    } catch (error) {
      if (error is DomainException) rethrow;
      throw NetworkException(
        mensajeRed ??
            'No pudimos conectar con el servidor de EduGuía. '
                'Revisa tu internet e intenta de nuevo.',
      );
    }
  }
}
