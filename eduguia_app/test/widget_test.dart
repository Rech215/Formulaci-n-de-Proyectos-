import 'package:eduguia_app/app.dart';
import 'package:eduguia_app/core/router/app_router.dart';
import 'package:eduguia_app/data/repositories/in_memory_edu_guia_repository.dart';
import 'package:eduguia_app/domain/usecases/edu_guia_use_cases.dart';
import 'package:eduguia_app/presentation/state/analysis_provider.dart';
import 'package:eduguia_app/presentation/state/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('muestra el hero de inicio y la navegación inferior',
      (tester) async {
    final useCases = EduGuiaUseCases(InMemoryEduGuiaRepository());
    final session = SessionProvider(useCases: useCases);
    final analysis = AnalysisProvider(useCases: useCases);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionProvider>.value(value: session),
          ChangeNotifierProvider<AnalysisProvider>.value(value: analysis),
        ],
        child: EduGuiaApp(router: AppRouter.router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Acompaña su aprendizaje'),
      findsOneWidget,
    );
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Planes'), findsWidgets);
  });
}
