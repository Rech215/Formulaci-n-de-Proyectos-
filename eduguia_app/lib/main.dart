import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'injection.dart';
import 'presentation/state/session_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = AppInjection();
  injection.session.initialize();

  runApp(
    ChangeNotifierProvider<SessionProvider>.value(
      value: injection.session,
      child: EduGuiaApp(router: AppRouter.router),
    ),
  );
}
