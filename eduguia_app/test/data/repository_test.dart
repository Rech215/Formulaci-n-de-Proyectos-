import 'package:eduguia_app/core/errors/domain_exception.dart';
import 'package:eduguia_app/data/repositories/in_memory_edu_guia_repository.dart';
import 'package:eduguia_app/domain/entities/hijo.dart';
import 'package:eduguia_app/domain/entities/suscripcion.dart';
import 'package:eduguia_app/domain/entities/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryEduGuiaRepository repository;

  setUp(() {
    repository = InMemoryEduGuiaRepository();
  });

  test(
    'registra padre con suscripción gratuita y evita correos duplicados',
    () async {
      final padre = await repository.registrarPadre(
        nombre: 'Ana',
        correo: 'ana@mail.com',
        password: 'secreto123',
      );

      final suscripcion = await repository.obtenerSuscripcion(padre.id);
      expect(suscripcion.tipoPlan, TipoPlan.gratuito);
      expect(suscripcion.limiteConsultas, isNull);

      await expectLater(
        repository.registrarPadre(
            nombre: 'Otra', correo: 'ANA@mail.com', password: 'secreto123'),
        throwsA(isA<DomainException>()),
      );
    },
  );

  test('permite escaneos ilimitados y cuenta el uso', () async {
    final padre = await repository.registrarPadre(
      nombre: 'Ana',
      correo: 'ana@mail.com',
      password: 'secreto123',
    );

    for (var i = 0; i < 8; i++) {
      await repository.crearTarea(
        padreId: padre.id,
        imagenUrl: 'https://img/$i.jpg',
        nombreHijo: 'Mateo',
      );
    }

    final suscripcion = await repository.obtenerSuscripcion(padre.id);
    expect(suscripcion.consultasUsadas, 8);
    expect(suscripcion.consultasRestantes, isNull);
    expect(suscripcion.puedeConsultar(), isTrue);
  });

  test('flujo de análisis y resumen de uso', () async {
    final padre = await repository.registrarPadre(
      nombre: 'Ana',
      correo: 'ana@mail.com',
      password: 'secreto123',
      hijos: <Hijo>[
        Hijo(nombre: 'Mateo', edad: 9, gradoEscolar: '4to Primaria'),
      ],
    );

    final tarea = await repository.crearTarea(
      padreId: padre.id,
      imagenUrl: 'https://img/1.jpg',
      nombreHijo: 'Mateo',
    );

    final analizando = await repository.iniciarAnalisisTarea(tarea.id);
    final completada = await repository.completarAnalisisTarea(
      analizando.id,
      ResultadoAnalisis(
        materia: 'Matemáticas',
        temaDetectado: 'Fracciones',
        metodoSep: 'Método SEP',
        preguntasGuia: const <String>['¿Qué observas?'],
      ),
    );

    expect(completada.estado, EstadoTarea.completada);

    final resumen = await repository.obtenerResumenUso(padre.id);
    expect(resumen.totalTareas, 1);
    expect(resumen.tareasCompletadas, 1);
    expect(resumen.cantidadHijos, 1);
  });

  test('upgrade a premium y cancelación', () async {
    final padre = await repository.registrarPadre(
      nombre: 'Ana',
      correo: 'ana@mail.com',
      password: 'secreto123',
    );

    final premium = await repository.actualizarPlan(padre.id, TipoPlan.premium);
    expect(premium.esPremium, isTrue);
    expect(premium.consultasRestantes, isNull);

    final padrePremium = await repository.obtenerPadre(padre.id);
    expect(padrePremium.planActual, TipoPlan.premium);

    final cancelada = await repository.cancelarSuscripcion(padre.id);
    expect(cancelada.estado, EstadoSuscripcion.cancelada);

    final padreFinal = await repository.obtenerPadre(padre.id);
    expect(padreFinal.planActual, TipoPlan.gratuito);
  });
}
