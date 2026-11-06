import '../../core/errors/domain_exception.dart';

class ApiException extends DomainException {
  const ApiException(
    super.message, {
    this.code = 'ERROR_API',
    this.status,
  });

  final String code;
  final int? status;

  bool get esNoAutorizado => status == 401;

  @override
  String toString() => message;
}
