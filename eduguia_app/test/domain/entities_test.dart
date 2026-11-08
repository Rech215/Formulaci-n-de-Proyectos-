import 'package:eduguia_app/core/errors/domain_exception.dart';
import 'package:eduguia_app/domain/entities/hijo.dart';
import 'package:eduguia_app/domain/entities/padre.dart';
import 'package:eduguia_app/domain/entities/suscripcion.dart';
import 'package:eduguia_app/domain/entities/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Padre', () {
    test('normaliza el correo y rechaza correos inválidos', () {
      final padre = Padre(id: 'p1', nombre: 'Ana', correo: '  ANA@MAIL.COM ');

      expect(padre.correo, 'ana@mail.com');
      expect(
        () => Padre(id: 'p2', nombre: 'Luis', correo: 'correo-invalido'),
        throwsA(isA<DomainException>()),
      );
    });

    test('agrega y elimina hijos sin mutar la instancia original', () {
      final padre = Padre(id: 'p1', nombre: 'Ana', correo: 'ana@mail.com');
      final conHijo = padre.agregarHijo(
        Hijo(nombre: 'Mateo', edad: 9, gradoEscolar: '4to Primaria'),
      );

      expect(padre.hijos, isEmpty);
      expect(conHijo.hijos, hasLength(1));
      expect(
        () => conHijo.agregarHijo(
          Hijo(nombre: 'mateo', edad: 10, gradoEscolar: '5to Primaria'),
        ),
        throwsA(isA<DomainException>()),
      );

      final sinHijo = conHijo.eliminarHijo('MATEO');
      expect(sinHijo.hijos, isEmpty);
    });

    test('rechaza edades fuera del rango permitido', () {
      expect(
        () => Hijo(nombre: 'Bebé', edad: 2, gradoEscolar: 'Maternal'),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('Tarea', () {
    test('respeta la máquina de estados', () {
      final tarea = Tarea(
        id: 't1',
        padreId: 'p1',
        imagenUrl: 'https://img/1.jpg',
        nombreHijo: 'Mateo',
      );

      expect(tarea.estado, EstadoTarea.pendiente);

      final analizando = tarea.iniciarAnalisis();
      expect(analizando.estado, EstadoTarea.analizando);
      expect(
        () => analizando.iniciarAnalisis(),
        throwsA(isA<DomainException>()),
      );

      final completada = analizando.completarAnalisis(
        ResultadoAnalisis(
          materia: 'Matemáticas',
          temaDetectado: 'Fracciones',
          metodoSep: 'Método SEP',
          preguntasGuia: const <String>['¿Qué observas?'],
        ),
      );

      expect(completada.estado, EstadoTarea.completada);
      expect(completada.preguntasGuia, hasLength(1));
      expect(
        () => completada.marcarError('falló'),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('Suscripcion', () {
    test('el plan gratuito es ilimitado y cuenta los escaneos', () {
      var suscripcion = Suscripcion(id: 's1', padreId: 'p1');

      expect(suscripcion.limiteConsultas, isNull);
      expect(suscripcion.consultasRestantes, isNull);

      for (var i = 0; i < 10; i++) {
        suscripcion = suscripcion.registrarConsulta();
      }

      expect(suscripcion.consultasUsadas, 10);
      expect(suscripcion.puedeConsultar(), isTrue);
      expect(suscripcion.esIlimitada, isTrue);
    });

    test('premium cuesta 69 y no permite cambiar al mismo plan', () {
      final premium = Suscripcion(
        id: 's1',
        padreId: 'p1',
        tipoPlan: TipoPlan.premium,
      );

      expect(premium.esIlimitada, isTrue);
      expect(premium.consultasRestantes, isNull);
      expect(premium.precioMensual, 69);

      var actual = premium;
      for (var i = 0; i < 20; i++) {
        actual = actual.registrarConsulta();
      }

      expect(actual.puedeConsultar(), isTrue);
      expect(
        () => actual.actualizarPlan(TipoPlan.premium),
        throwsA(isA<DomainException>()),
      );

      final gratuito = actual.actualizarPlan(TipoPlan.gratuito);
      expect(gratuito.limiteConsultas, isNull);
      expect(gratuito.esPremium, isFalse);
    });
  });
}
