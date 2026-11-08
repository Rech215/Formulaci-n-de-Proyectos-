import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/entities/suscripcion.dart';
import '../../domain/repositories/pagos_repository.dart';
import '../remote/api_client.dart';
import '../remote/api_exception.dart';

class PagosService implements PagosRepository {
  PagosService({
    required ApiClient apiClient,
    required String entitlementId,
    required String googleApiKey,
    required String appleApiKey,
  })  : _apiClient = apiClient,
        _entitlementId = entitlementId,
        _googleApiKey = googleApiKey,
        _appleApiKey = appleApiKey;

  final ApiClient _apiClient;
  final String _entitlementId;
  final String _googleApiKey;
  final String _appleApiKey;

  bool _configurado = false;
  String? _appUserId;

  String get _apiKey {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return _appleApiKey;
    }
    return _googleApiKey;
  }

  @override
  Future<void> inicializar({required String appUserId}) async {
    if (_configurado) {
      if (_appUserId != appUserId) {
        await Purchases.logIn(appUserId);
        _appUserId = appUserId;
      }
      return;
    }

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw const PagoException(
        'Falta configurar la llave de RevenueCat para esta plataforma.',
      );
    }

    final configuracion = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(configuracion);

    _configurado = true;
    _appUserId = appUserId;
  }

  @override
  Future<bool> esPremium() async {
    _verificarConfiguracion();
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(_entitlementId);
  }

  @override
  Future<Suscripcion?> comprarPremium() async {
    _verificarConfiguracion();

    try {
      final ofertas = await Purchases.getOfferings();
      final paquete = _seleccionarPaquete(ofertas.current);

      if (paquete == null) {
        throw const PagoException(
          'No hay un paquete de suscripción disponible en la tienda.',
        );
      }

      final resultado = await Purchases.purchase(
        PurchaseParams.package(paquete),
      );

      final activo = resultado.customerInfo.entitlements.active.containsKey(
        _entitlementId,
      );

      if (!activo) {
        throw const PagoException(
          'La compra se completó, pero la suscripción Premium aún no está activa. '
          'Intenta restaurar tus compras.',
        );
      }

      return await _validarEnBackend();
    } on PlatformException catch (error) {
      final codigo = PurchasesErrorHelper.getErrorCode(error);
      if (codigo == PurchasesErrorCode.purchaseCancelledError) {
        return null;
      }
      throw PagoException(_mensajeDeError(codigo, error.message));
    }
  }

  @override
  Future<Suscripcion?> restaurarCompras() async {
    _verificarConfiguracion();

    try {
      await Purchases.restorePurchases();
      return await _validarEnBackend();
    } on PlatformException catch (error) {
      final codigo = PurchasesErrorHelper.getErrorCode(error);
      throw PagoException(_mensajeDeError(codigo, error.message));
    }
  }

  Package? _seleccionarPaquete(Offering? oferta) {
    if (oferta == null || oferta.availablePackages.isEmpty) return null;

    for (final paquete in oferta.availablePackages) {
      if (paquete.packageType == PackageType.monthly) {
        return paquete;
      }
    }

    return oferta.availablePackages.first;
  }

  Future<Suscripcion?> _validarEnBackend() async {
    try {
      final datos = await _apiClient.postJson('/suscripcion/validar');
      final suscripcion = datos['suscripcion'];
      if (suscripcion is Map) {
        return Suscripcion.fromJson(Map<String, dynamic>.from(suscripcion));
      }
      return null;
    } on ApiException catch (error) {
      throw PagoException(
        'La compra se realizó, pero no pudimos actualizar tu cuenta: '
        '${error.message}',
      );
    }
  }

  void _verificarConfiguracion() {
    if (!_configurado) {
      throw const PagoException(
        'RevenueCat todavía no está inicializado para este usuario.',
      );
    }
  }

  String _mensajeDeError(PurchasesErrorCode codigo, String? mensaje) {
    return switch (codigo) {
      PurchasesErrorCode.networkError =>
        'No hay conexión con la tienda. Revisa tu internet e intenta de nuevo.',
      PurchasesErrorCode.purchaseNotAllowedError =>
        'La tienda no permitió realizar la compra en este dispositivo.',
      PurchasesErrorCode.productAlreadyPurchasedError =>
        'Ya tienes esta suscripción activa. Usa "Restaurar compras".',
      PurchasesErrorCode.paymentPendingError =>
        'Tu pago está pendiente de confirmación por la tienda.',
      _ => mensaje == null || mensaje.isEmpty
          ? 'No pudimos completar la compra. Intenta de nuevo.'
          : 'No pudimos completar la compra: $mensaje',
    };
  }
}
