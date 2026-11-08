import 'domain_exception.dart';

/// No hay conexión a internet o el dispositivo no pudo alcanzar el servidor.
class NetworkException extends DomainException {
  const NetworkException([
    super.message =
        'No hay conexión a internet. Revisa tu red e intenta de nuevo.',
  ]);
}

/// La operación tardó más de lo permitido (por ejemplo, la IA no respondió).
class TimeoutException extends DomainException {
  const TimeoutException([
    super.message =
        'La IA tardó demasiado en responder. Intenta con una foto más ligera.',
  ]);
}

/// El servidor Node.js respondió con un error o con datos inválidos.
class ServerException extends DomainException {
  const ServerException(super.message, {this.code, this.statusCode});

  final String? code;
  final int? statusCode;

  bool get esNoAutorizado => statusCode == 401;

  @override
  String toString() => message;
}
