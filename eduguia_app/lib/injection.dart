import 'data/repositories/api_edu_guia_repository.dart';
import 'data/repositories/in_memory_edu_guia_repository.dart';
import 'data/remote/api_client.dart';
import 'data/remote/api_config.dart';
import 'data/remote/token_storage.dart';
import 'data/services/pagos_service.dart';
import 'domain/repositories/edu_guia_repository.dart';
import 'domain/repositories/pagos_repository.dart';
import 'domain/usecases/edu_guia_use_cases.dart';
import 'presentation/state/analysis_provider.dart';
import 'presentation/state/session_provider.dart';

class AppInjection {
  AppInjection() {
    const usarMock = bool.fromEnvironment(
      'EDUGUIA_USAR_MOCK',
      defaultValue: false,
    );

    if (usarMock) {
      apiClient = null;
      pagosRepository = null;
      repository = InMemoryEduGuiaRepository();
    } else {
      final cliente = ApiClient(
        baseUrl: ApiConfig.baseUrl,
        tokenStorage: SecureTokenStorage(),
      );
      apiClient = cliente;
      repository = ApiEduGuiaRepository(apiClient: cliente);
      pagosRepository = PagosService(
        apiClient: cliente,
        entitlementId: const String.fromEnvironment(
          'REVENUECAT_ENTITLEMENT_ID',
          defaultValue: 'premium',
        ),
        googleApiKey: const String.fromEnvironment(
          'REVENUECAT_GOOGLE_API_KEY',
        ),
        appleApiKey: const String.fromEnvironment(
          'REVENUECAT_APPLE_API_KEY',
        ),
      );
    }

    useCases = EduGuiaUseCases(repository);
    session = SessionProvider(
      useCases: useCases,
      pagosRepository: pagosRepository,
    );
    analysis = AnalysisProvider(useCases: useCases);
  }

  late final ApiClient? apiClient;
  late final PagosRepository? pagosRepository;
  late final EduGuiaRepository repository;
  late final EduGuiaUseCases useCases;
  late final SessionProvider session;
  late final AnalysisProvider analysis;
}
