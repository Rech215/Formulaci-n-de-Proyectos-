import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import 'in_memory_edu_guia_repository.dart';

/// Repositorio simulado para desarrollo.
///
/// Añade una latencia artificial a las operaciones de autenticación para que
/// la UI muestre el indicador de carga, pero siempre resuelve con éxito sin
/// quedarse colgado esperando a un backend.
class MockEduGuiaRepository extends InMemoryEduGuiaRepository {
  MockEduGuiaRepository();

  static const Duration _latenciaRed = Duration(seconds: 2);

  @override
  Future<Padre> registrarPadre({
    required String nombre,
    required String correo,
    required String password,
    List<Hijo> hijos = const <Hijo>[],
  }) async {
    await Future<void>.delayed(_latenciaRed);

    final existente = buscarPadrePorCorreo(correo);
    if (existente != null) {
      activarSesion(existente.id);
      return existente;
    }

    return super.registrarPadre(
      nombre: nombre,
      correo: correo,
      password: password,
      hijos: hijos,
    );
  }

  @override
  Future<Padre> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    await Future<void>.delayed(_latenciaRed);

    final existente = buscarPadrePorCorreo(correo);
    if (existente != null) {
      activarSesion(existente.id);
      return existente;
    }

    final usuario = correo.trim().split('@').first;
    final nombre = usuario.isEmpty ? 'Familia' : usuario;

    return super.registrarPadre(
      nombre: nombre,
      correo: correo,
      password: password,
    );
  }
}
