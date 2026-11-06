import '../../core/errors/domain_exception.dart';
import '../entities/suscripcion.dart';

class PagoException extends DomainException {
  const PagoException(super.message);
}

abstract class PagosRepository {
  Future<void> inicializar({required String appUserId});

  Future<bool> esPremium();

  Future<Suscripcion?> comprarPremium();

  Future<Suscripcion?> restaurarCompras();
}
