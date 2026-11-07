import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'injection.dart';
import 'presentation/state/analysis_provider.dart';
import 'presentation/state/session_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final session = getIt<SessionProvider>();
  final analysis = getIt<AnalysisProvider>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>.value(value: session),
        ChangeNotifierProvider<AnalysisProvider>.value(value: analysis),
      ],
      child: EduGuiaApp(router: AppRouter.router),
    ),
  );

  unawaited(session.initialize());
}
