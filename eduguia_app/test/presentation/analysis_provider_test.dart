import 'package:eduguia_app/data/repositories/in_memory_edu_guia_repository.dart';
import 'package:eduguia_app/domain/entities/hijo.dart';
import 'package:eduguia_app/domain/usecases/edu_guia_use_cases.dart';
import 'package:eduguia_app/presentation/state/analysis_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EduGuiaUseCases useCases;
  late AnalysisProvider analysisProvider;

  setUp(() {
    useCases = EduGuiaUseCases(InMemoryEduGuiaRepository());
    analysisProvider = AnalysisProvider(useCases: useCases);
  });

  test('estado inicial del analysis provider es inactivo', () {
    expect(analysisProvider.estado, EstadoAnalisis.inactivo);
    expect(analysisProvider.tareaActual, isNull);
    expect(analysisProvider.error, isNull);
  });

  test('flujo completo de análisis simula IA y completa con resultado SEP',
      () async {
    final padre = await useCases.registrarPadre(
      nombre: 'Carlos',
      correo: 'carlos@mail.com',
      hijos: <Hijo>[
        Hijo(nombre: 'Sofía', edad: 8, gradoEscolar: '3ro Primaria'),
      ],
    );

    await analysisProvider.analizarTarea(
      padreId: padre.id,
      imagenUrl: 'path/to/tarea.jpg',
      nombreHijo: 'Sofía',
    );

    expect(analysisProvider.estado, EstadoAnalisis.completado);
    expect(analysisProvider.tareaActual, isNotNull);
    expect(analysisProvider.tareaActual!.materia.isNotEmpty, isTrue);
    expect(analysisProvider.tareaActual!.metodoSep.isNotEmpty, isTrue);
    expect(analysisProvider.tareaActual!.preguntasGuia, isNotEmpty);
  });

  test('reiniciar limpia el estado al valor inactivo', () async {
    final padre = await useCases.registrarPadre(
      nombre: 'Carlos',
      correo: 'carlos2@mail.com',
    );

    await analysisProvider.analizarTarea(
      padreId: padre.id,
      imagenUrl: 'path/to/tarea.jpg',
      nombreHijo: 'Sofía',
    );

    expect(analysisProvider.estado, EstadoAnalisis.completado);
    analysisProvider.reiniciar();
    expect(analysisProvider.estado, EstadoAnalisis.inactivo);
    expect(analysisProvider.tareaActual, isNull);
  });
}

