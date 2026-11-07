import '../../core/errors/network_exceptions.dart';

/// Error devuelto por la API HTTP de EduGuía.
///
/// Extiende [ServerException] para que la capa de presentación pueda tratar
/// todos los errores del servidor de la misma forma.
class ApiException extends ServerException {
  const ApiException(
    super.message, {
    super.code = 'ERROR_API',
    super.statusCode,
  });

  int? get status => statusCode;

  @override
  String toString() => message;
}
