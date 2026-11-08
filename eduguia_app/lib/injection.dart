import 'package:get_it/get_it.dart';

import 'data/remote/api_client.dart';
import 'data/remote/api_config.dart';
import 'data/remote/token_storage.dart';
import 'data/repositories/api_edu_guia_repository.dart';
import 'data/repositories/mock_edu_guia_repository.dart';
import 'data/repositories/mock_pagos_repository.dart';
import 'data/services/historial_service.dart';
import 'data/services/image_cropper_service.dart';
import 'data/services/pagos_service.dart';
import 'domain/repositories/edu_guia_repository.dart';
import 'domain/repositories/historial_repository.dart';
import 'domain/repositories/pagos_repository.dart';
import 'domain/services/image_editor_service.dart';
import 'domain/usecases/edu_guia_use_cases.dart';
import 'presentation/state/analysis_provider.dart';
import 'presentation/state/onboarding_provider.dart';
import 'presentation/state/session_provider.dart';

final GetIt getIt = GetIt.instance;

/// Registra todas las dependencias de la aplicación.
///
/// Cuando [useMocks] es true se usa [MockEduGuiaRepository]; de lo contrario
/// se conecta al backend Node.js mediante [ApiEduGuiaRepository].
Future<void> configureDependencies({bool? useMocks}) async {
  await ApiConfig.load();

  final usarMocks = useMocks ?? ApiConfig.useMocks;

  getIt.registerLazySingleton<HistorialRepository>(() => HistorialService());
  getIt.registerLazySingleton<ImageEditorService>(() => ImageCropperService());
  getIt.registerLazySingleton<OnboardingProvider>(() => OnboardingProvider());

  getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: ApiConfig.baseUrl,
      tokenStorage: getIt<TokenStorage>(),
      timeout: ApiConfig.timeout,
    ),
  );

  getIt.registerLazySingleton<BaseEduGuiaRepository>(
    () => usarMocks
        ? MockEduGuiaRepository()
        : ApiEduGuiaRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<EduGuiaUseCases>(
    () => EduGuiaUseCases(getIt<BaseEduGuiaRepository>()),
  );

  getIt.registerLazySingleton<PagosRepository>(
    () => _crearPagosRepository(usarMocks),
  );

  getIt.registerLazySingleton<SessionProvider>(
    () => SessionProvider(
      useCases: getIt<EduGuiaUseCases>(),
      pagosRepository: getIt<PagosRepository>(),
    ),
  );

  getIt.registerLazySingleton<AnalysisProvider>(
    () => AnalysisProvider(
      useCases: getIt<EduGuiaUseCases>(),
      latenciaSimulada:
          usarMocks ? const Duration(milliseconds: 2600) : Duration.zero,
    ),
  );
}

PagosRepository _crearPagosRepository(bool usarMocks) {
  if (usarMocks) {
    return MockPagosRepository(
      eduGuiaRepository: getIt<BaseEduGuiaRepository>(),
    );
  }

  const googleApiKey = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
  const appleApiKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  const entitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT_ID',
    defaultValue: 'premium',
  );

  if (googleApiKey.isEmpty && appleApiKey.isEmpty) {
    return MockPagosRepository(
      eduGuiaRepository: getIt<BaseEduGuiaRepository>(),
    );
  }

  return PagosService(
    apiClient: getIt<ApiClient>(),
    entitlementId: entitlementId,
    googleApiKey: googleApiKey,
    appleApiKey: appleApiKey,
  );
}
