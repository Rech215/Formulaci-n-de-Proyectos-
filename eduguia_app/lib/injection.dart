import 'data/repositories/in_memory_edu_guia_repository.dart';
import 'domain/repositories/edu_guia_repository.dart';
import 'domain/usecases/edu_guia_use_cases.dart';
import 'presentation/state/session_provider.dart';

/// Contenedor de dependencias (Clean Architecture).
///
/// Dominio ← Casos de uso ← Presentación
/// Dominio ← Repositorio (contrato)
/// Datos  → Repositorio (implementación)
class AppInjection {
  AppInjection() {
    repository = InMemoryEduGuiaRepository();
    useCases = EduGuiaUseCases(repository);
    session = SessionProvider(useCases: useCases);
  }

  late final EduGuiaRepository repository;
  late final EduGuiaUseCases useCases;
  late final SessionProvider session;
}
