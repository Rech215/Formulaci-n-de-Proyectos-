import 'package:eduguia_app/data/services/scan_quota_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('cuenta escaneos por padre y se reinicia al cambiar de día', () async {
    var hoy = DateTime(2026, 3, 10, 9);
    final servicio = ScanQuotaService(ahora: () => hoy);

    expect(await servicio.obtenerUsadosHoy('padre-1'), 0);
    expect(await servicio.registrarEscaneo('padre-1'), 1);
    expect(await servicio.registrarEscaneo('padre-1'), 2);
    expect(await servicio.obtenerUsadosHoy('padre-1'), 2);

    expect(await servicio.obtenerUsadosHoy('padre-2'), 0);

    hoy = DateTime(2026, 3, 11, 7);
    expect(await servicio.obtenerUsadosHoy('padre-1'), 0);
    expect(await servicio.registrarEscaneo('padre-1'), 1);
  });

  test('reinicia manualmente el contador del día', () async {
    final servicio = ScanQuotaService(ahora: () => DateTime(2026, 4, 1));

    await servicio.registrarEscaneo('padre-1');
    await servicio.registrarEscaneo('padre-1');
    await servicio.reiniciar('padre-1');

    expect(await servicio.obtenerUsadosHoy('padre-1'), 0);
  });
}
