import 'package:eduguia_app/app.dart';
import 'package:eduguia_app/core/router/app_router.dart';
import 'package:eduguia_app/data/repositories/in_memory_edu_guia_repository.dart';
import 'package:eduguia_app/domain/entities/hijo.dart';
import 'package:eduguia_app/domain/usecases/edu_guia_use_cases.dart';
import 'package:eduguia_app/presentation/state/analysis_provider.dart';
import 'package:eduguia_app/presentation/state/onboarding_provider.dart';
import 'package:eduguia_app/presentation/state/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('muestra el inicio móvil después de autenticarse', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final useCases = EduGuiaUseCases(InMemoryEduGuiaRepository());
    final session = SessionProvider(useCases: useCases);
    final analysis = AnalysisProvider(useCases: useCases);
    final onboarding = OnboardingProvider();

    await onboarding.cargar();
    await onboarding.completar();
    await session.registrar(
      nombre: 'Ana',
      correo: 'ana@mail.com',
      password: 'secreto123',
      hijos: <Hijo>[
        Hijo(nombre: 'Mateo', edad: 9, gradoEscolar: '4to Primaria'),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionProvider>.value(value: session),
          ChangeNotifierProvider<AnalysisProvider>.value(value: analysis),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
        ],
        child: EduGuiaApp(
          router: AppRouter.create(session: session, onboarding: onboarding),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Escanea una tarea'), findsWidgets);
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Historial'), findsWidgets);
    expect(find.text('Premium'), findsWidgets);
  });
}
