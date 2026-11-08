import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import '../../domain/entities/resumen_uso.dart';
import '../../domain/entities/suscripcion.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/edu_guia_repository.dart';
import '../remote/api_client.dart';
import '../remote/api_exception.dart';

class ApiEduGuiaRepository implements BaseEduGuiaRepository {
  ApiEduGuiaRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Padre> registrarPadre({
    required String nombre,
    required String correo,
    required String password,
    List<Hijo> hijos = const <Hijo>[],
  }) async {
    final datos = await _api.postJson(
      '/auth/registro',
      body: <String, dynamic>{
        'nombre': nombre,
        'correo': correo,
        'password': password,
        'hijos': hijos.map((hijo) => hijo.toJson()).toList(growable: false),
      },
    );

    await _guardarToken(datos);
    return _padreDesde(datos['padre']);
  }

  @override
  Future<Padre> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final datos = await _api.postJson(
      '/auth/login',
      body: <String, dynamic>{'correo': correo, 'password': password},
    );

    await _guardarToken(datos);
    return _padreDesde(datos['padre']);
  }

  @override
  Future<Padre?> restaurarSesion() async {
    if (!await _api.tieneToken()) return null;

    try {
      final datos = await _api.getJson('/auth/perfil');
      return _padreDesde(datos['padre']);
    } on ApiException catch (error) {
      if (error.esNoAutorizado) {
        await _api.cerrarSesion();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> cerrarSesion() => _api.cerrarSesion();

  @override
  Future<Padre> obtenerPadre(String padreId) async {
    final datos = await _api.getJson('/auth/perfil');
    return _padreDesde(datos['padre']);
  }

  @override
  Future<Padre> agregarHijo(String padreId, Hijo hijo) async {
    final datos = await _api.postJson('/hijos', body: hijo.toJson());
    return _padreDesde(datos['padre']);
  }

  @override
  Future<Padre> eliminarHijo(String padreId, String nombreHijo) async {
    final nombre = Uri.encodeQueryComponent(nombreHijo);
    final datos = await _api.deleteJson('/hijos?nombre=$nombre');
    return _padreDesde(datos['padre']);
  }

  @override
  Future<Tarea> analizarTarea({
    required String padreId,
    required String imagenPath,
    required String nombreHijo,
    String materiaSugerida = '',
  }) async {
    final datos = await _api.postMultipart(
      '/tareas/analizar',
      fields: <String, String>{
        'nombreHijo': nombreHijo,
        'materiaSugerida': materiaSugerida,
      },
      filePath: imagenPath,
    );

    return _tareaDesde(datos['tarea']);
  }

  @override
  Future<Tarea> crearTarea({
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
  }) {
    throw UnsupportedError(
      'El backend analiza la tarea en una sola operación. '
      'Usa analizarTarea().',
    );
  }

  @override
  Future<Tarea> iniciarAnalisisTarea(String tareaId) {
    throw UnsupportedError(
      'El backend controla el estado del análisis. Usa analizarTarea().',
    );
  }

  @override
  Future<Tarea> completarAnalisisTarea(
    String tareaId,
    ResultadoAnalisis resultado,
  ) {
    throw UnsupportedError(
      'El backend genera el resultado. Usa analizarTarea().',
    );
  }

  @override
  Future<Tarea> marcarErrorTarea(String tareaId, String mensaje) {
    throw UnsupportedError(
      'El backend controla el estado del análisis. Usa analizarTarea().',
    );
  }

  @override
  Future<List<Tarea>> obtenerTareasPorPadre(String padreId) async {
    final datos = await _api.getJson('/tareas?limite=50');
    final tareas = datos['tareas'];

    if (tareas is! List) {
      throw const ApiException(
        'El servidor devolvió un historial con formato inválido.',
        code: 'RESPUESTA_INVALIDA',
      );
    }

    return tareas.map((item) => _tareaDesde(item)).toList(growable: false);
  }

  @override
  Future<Tarea> obtenerTarea(String tareaId) async {
    final datos = await _api.getJson('/tareas/${Uri.encodeComponent(tareaId)}');
    return _tareaDesde(datos['tarea']);
  }

  @override
  Future<Suscripcion> obtenerSuscripcion(String padreId) async {
    final datos = await _api.getJson('/suscripcion');
    return _suscripcionDesde(datos['suscripcion']);
  }

  @override
  Future<Suscripcion> validarSuscripcion() async {
    final datos = await _api.postJson('/suscripcion/validar');
    return _suscripcionDesde(datos['suscripcion']);
  }

  @override
  Future<Suscripcion> actualizarPlan(String padreId, TipoPlan nuevoPlan) {
    if (nuevoPlan == TipoPlan.premium) {
      return validarSuscripcion();
    }
    return cancelarSuscripcion(padreId);
  }

  @override
  Future<Suscripcion> cancelarSuscripcion(String padreId) async {
    final datos = await _api.postJson('/suscripcion/cancelar');
    return _suscripcionDesde(datos['suscripcion']);
  }

  @override
  Future<bool> puedeConsultar(String padreId) async {
    final suscripcion = await obtenerSuscripcion(padreId);
    return suscripcion.puedeConsultar();
  }

  @override
  Future<ResumenUso> obtenerResumenUso(String padreId) async {
    final datos = await _api.getJson('/resumen');
    final resumen = datos['resumen'];

    if (resumen is! Map) {
      throw const ApiException(
        'El servidor devolvió un resumen con formato inválido.',
        code: 'RESPUESTA_INVALIDA',
      );
    }

    return ResumenUso.fromJson(Map<String, dynamic>.from(resumen));
  }

  Future<void> _guardarToken(Map<String, dynamic> datos) async {
    final token = datos['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'El servidor no devolvió un token de acceso.',
        code: 'RESPUESTA_INVALIDA',
      );
    }
    await _api.guardarToken(token);
  }

  Padre _padreDesde(dynamic valor) {
    return Padre.fromJson(_mapa(valor, 'perfil'));
  }

  Suscripcion _suscripcionDesde(dynamic valor) {
    return Suscripcion.fromJson(_mapa(valor, 'suscripción'));
  }

  Tarea _tareaDesde(dynamic valor) {
    return Tarea.fromJson(_mapa(valor, 'tarea'));
  }

  Map<String, dynamic> _mapa(dynamic valor, String nombre) {
    if (valor is! Map) {
      throw ApiException(
        'El servidor devolvió $nombre con formato inválido.',
        code: 'RESPUESTA_INVALIDA',
      );
    }
    return Map<String, dynamic>.from(valor);
  }
}
