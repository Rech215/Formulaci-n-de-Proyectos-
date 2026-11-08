import 'package:eduguia_app/data/services/historial_service.dart';
import 'package:eduguia_app/domain/entities/tarea.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('HistorialService', () {
    Tarea crearTarea(String id, DateTime fecha) {
      return Tarea(
        id: id,
        padreId: 'padre-1',
        imagenUrl: 'file:///tmp/$id.jpg',
        nombreHijo: 'Mateo',
        estado: EstadoTarea.completada,
        materia: 'Matemáticas',
        temaDetectado: 'Fracciones',
        metodoSep: 'Dividir el entero en partes iguales.',
        preguntasGuia: const <String>['¿Qué fracción representa?'],
        fechaCreacion: fecha,
      );
    }

    test('guarda, ordena por fecha y elimina entradas', () async {
      final servicio = HistorialService();
      final vieja = crearTarea('vieja', DateTime(2026, 1, 1));
      final nueva = crearTarea('nueva', DateTime(2026, 2, 1));

      await servicio.guardar('padre-1', vieja);
      await servicio.guardar('padre-1', nueva);

      final tareas = await servicio.obtener('padre-1');
      expect(tareas.map((tarea) => tarea.id), <String>['nueva', 'vieja']);

      await servicio.eliminar('padre-1', 'nueva');
      expect((await servicio.obtener('padre-1')).single.id, 'vieja');

      await servicio.limpiar('padre-1');
      expect(await servicio.obtener('padre-1'), isEmpty);
    });

    test('ignora JSON corrupto y reemplaza por identificador', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'eduguia_historial_padre-1': 'no-es-json',
      });
      final servicio = HistorialService();

      expect(await servicio.obtener('padre-1'), isEmpty);

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final tarea = crearTarea('tarea-1', DateTime(2026, 3, 1));
      await servicio.guardar('padre-1', tarea);
      await servicio.guardar('padre-1', tarea.copyWith(materia: 'Español'));

      final tareas = await servicio.obtener('padre-1');
      expect(tareas.single.id, 'tarea-1');
      expect(tareas.single.materia, 'Español');
    });
  });
}
