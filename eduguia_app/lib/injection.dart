import 'data/repositories/mock_edu_guia_repository.dart';
import 'data/repositories/mock_pagos_repository.dart';
import 'domain/repositories/edu_guia_repository.dart';
import 'domain/repositories/pagos_repository.dart';
import 'domain/usecases/edu_guia_use_cases.dart';
import 'presentation/state/analysis_provider.dart';
import 'presentation/state/session_provider.dart';

class AppInjection {
  AppInjection() {
    final mockRepository = MockEduGuiaRepository();

    repository = mockRepository;
    pagosRepository = MockPagosRepository(
      eduGuiaRepository: mockRepository,
    );
    useCases = EduGuiaUseCases(repository);
    session = SessionProvider(
      useCases: useCases,
      pagosRepository: pagosRepository,
    );
    analysis = AnalysisProvider(
      useCases: useCases,
      latenciaSimulada: const Duration(milliseconds: 2600),
    );
  }

  late final PagosRepository pagosRepository;
  late final EduGuiaRepository repository;
  late final EduGuiaUseCases useCases;
  late final SessionProvider session;
  late final AnalysisProvider analysis;
}
