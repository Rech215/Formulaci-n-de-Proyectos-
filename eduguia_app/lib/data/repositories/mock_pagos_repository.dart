import '../../domain/entities/suscripcion.dart';
import '../../domain/repositories/edu_guia_repository.dart';
import '../../domain/repositories/pagos_repository.dart';

class MockPagosRepository implements PagosRepository {
  MockPagosRepository({required BaseEduGuiaRepository eduGuiaRepository})
      : _eduGuiaRepository = eduGuiaRepository;

  final BaseEduGuiaRepository _eduGuiaRepository;

  String? _appUserId;
  bool _configurado = false;

  @override
  Future<void> inicializar({required String appUserId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _appUserId = appUserId;
    _configurado = true;
  }

  @override
  Future<bool> esPremium() async {
    final suscripcion = await _suscripcionActual();
    return suscripcion?.esPremium ?? false;
  }

  @override
  Future<Suscripcion?> comprarPremium() async {
    _verificarConfiguracion();
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final suscripcion = await _suscripcionActual();
    if (suscripcion == null) return null;
    if (suscripcion.esPremium) return suscripcion;

    return _eduGuiaRepository.actualizarPlan(
      _appUserId!,
      TipoPlan.premium,
    );
  }

  @override
  Future<Suscripcion?> restaurarCompras() async {
    _verificarConfiguracion();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final suscripcion = await _suscripcionActual();
    if (suscripcion == null || !suscripcion.esPremium) return null;
    return suscripcion;
  }

  Future<Suscripcion?> _suscripcionActual() async {
    final appUserId = _appUserId;
    if (appUserId == null) return null;
    return _eduGuiaRepository.obtenerSuscripcion(appUserId);
  }

  void _verificarConfiguracion() {
    if (!_configurado || _appUserId == null) {
      throw const PagoException(
        'El servicio de pagos simulado aún no está inicializado.',
      );
    }
  }
}
