import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'injection.dart';
import 'presentation/state/analysis_provider.dart';
import 'presentation/state/session_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = AppInjection();
  injection.session.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>.value(
          value: injection.session,
        ),
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: injection.analysis,
        ),
      ],
      child: EduGuiaApp(router: AppRouter.router),
    ),
  );
}
