import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/tarea.dart';
import '../../domain/repositories/historial_repository.dart';

/// Historial local de tareas serializado como JSON en `shared_preferences`.
///
/// Guarda únicamente el resultado pedagógico (materia, tema, método y
/// preguntas guía); nunca la fotografía. El historial es temporal y está
/// pensado para migrarse a Hive o SQLite más adelante.
class HistorialService implements HistorialRepository {
  static const String _prefijo = 'eduguia_historial_';
  static const int _maximoEntradas = 100;

  String _clave(String padreId) => '$_prefijo$padreId';

  @override
  Future<List<Tarea>> obtener(String padreId) async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString(_clave(padreId));

    if (crudo == null || crudo.trim().isEmpty) {
      return const <Tarea>[];
    }

    try {
      final decodificado = jsonDecode(crudo);
      if (decodificado is! List) return const <Tarea>[];

      final tareas = <Tarea>[];
      for (final item in decodificado) {
        if (item is! Map) continue;
        try {
          tareas.add(Tarea.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Ignora entradas corruptas o de versiones anteriores.
        }
      }

      tareas.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return List<Tarea>.unmodifiable(tareas);
    } catch (_) {
      return const <Tarea>[];
    }
  }

  @override
  Future<void> guardar(String padreId, Tarea tarea) async {
    final prefs = await SharedPreferences.getInstance();
    final actuales = (await obtener(padreId)).toList();

    actuales.removeWhere((item) => item.id == tarea.id);
    actuales.insert(0, tarea);

    final serializadas = actuales
        .take(_maximoEntradas)
        .map((item) => item.toJson())
        .toList(growable: false);

    await prefs.setString(_clave(padreId), jsonEncode(serializadas));
  }

  @override
  Future<void> eliminar(String padreId, String tareaId) async {
    final prefs = await SharedPreferences.getInstance();
    final actuales = (await obtener(padreId))
        .where((item) => item.id != tareaId)
        .map((item) => item.toJson())
        .toList(growable: false);

    await prefs.setString(_clave(padreId), jsonEncode(actuales));
  }

  @override
  Future<void> limpiar(String padreId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave(padreId));
  }
}
