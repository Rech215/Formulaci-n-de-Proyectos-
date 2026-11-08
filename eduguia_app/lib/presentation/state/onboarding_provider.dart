import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla si el tutorial inicial ya fue visto en este dispositivo.
///
/// La marca se persiste con `shared_preferences`, por lo que el onboarding
/// se muestra únicamente la primera vez que se instala y abre la app.
class OnboardingProvider extends ChangeNotifier {
  static const String _clave = 'eduguia_onboarding_completado_v1';

  bool _cargando = true;
  bool _completado = false;

  bool get cargando => _cargando;
  bool get completado => _completado;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _completado = prefs.getBool(_clave) ?? false;
    _cargando = false;
    notifyListeners();
  }

  Future<void> completar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, true);
    _completado = true;
    notifyListeners();
  }

  Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
    _completado = false;
    notifyListeners();
  }
}
