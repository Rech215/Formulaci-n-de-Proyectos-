import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/historial_repository.dart';
import '../../injection.dart';
import '../state/session_provider.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  List<Tarea> _tareas = const <Tarea>[];
  bool _cargando = true;
  bool _inicializado = false;
  String? _padreId;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<SessionProvider>();
    final padreId = session.padre?.id;

    if (!_inicializado || padreId != _padreId) {
      _inicializado = true;
      _padreId = padreId;

      if (padreId == null) {
        setState(() {
          _tareas = const <Tarea>[];
          _error = null;
          _cargando = session.cargando;
        });
      } else {
        _cargar(padreId);
      }
    }
  }

  Future<void> _cargar(String padreId) async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final tareas = await getIt<HistorialRepository>().obtener(padreId);
      if (!mounted || _padreId != padreId) return;
      setState(() {
        _tareas = tareas;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted || _padreId != padreId) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudo cargar el historial.';
      });
    }
  }

  Future<void> _eliminar(Tarea tarea) async {
    final padreId = _padreId;
    if (padreId == null) return;

    await getIt<HistorialRepository>().eliminar(padreId, tarea.id);
    if (!mounted) return;

    setState(() {
      _tareas =
          _tareas.where((item) => item.id != tarea.id).toList(growable: false);
    });
  }

  Future<void> _limpiar() async {
    final padreId = _padreId;
    if (padreId == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text(
          'Se eliminarán todas las tareas guardadas en este dispositivo. '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red600),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await getIt<HistorialRepository>().limpiar(padreId);
    if (!mounted) return;
    setState(() => _tareas = const <Tarea>[]);
  }

  @override
  Widget build(BuildContext context) {
    final contenido = _cargando
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.brand600),
            ),
          )
        : _error != null
            ? _buildError()
            : _tareas.isEmpty
                ? _buildVacio()
                : Column(
                    children: <Widget>[
                      for (final tarea in _tareas) _buildTarea(tarea),
                    ],
                  );

    return RefreshIndicator(
      color: AppColors.brand600,
      onRefresh: () async {
        final padreId = _padreId;
        if (padreId != null) await _cargar(padreId);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildEncabezado(),
                  const SizedBox(height: 20),
                  contenido,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'HISTORIAL',
          style: TextStyle(
            color: AppColors.brand600,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tareas que ya acompañaste',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Repasa las preguntas guía y el método SEP sin volver a escanear. '
          'Solo se guarda en este dispositivo.',
          style: TextStyle(
            color: AppColors.slate500,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (_tareas.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _limpiar,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Limpiar historial'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.red600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Row(
      children: <Widget>[
        const Icon(Icons.error_outline, color: AppColors.red600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _error ?? 'No se pudo cargar el historial.',
            style: const TextStyle(color: AppColors.red600),
          ),
        ),
        TextButton(
          onPressed: () {
            final padreId = _padreId;
            if (padreId != null) _cargar(padreId);
          },
          child: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _buildVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.brand200),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.history_edu_outlined,
            size: 48,
            color: AppColors.brand600,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay tareas guardadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando analices una tarea, aparecerá aquí para que puedas '
            'repasar las preguntas guía con tu hijo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/escanear'),
            icon: const Icon(Icons.photo_camera_outlined, size: 20),
            label: const Text('Escanear una tarea'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarea(Tarea tarea) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.slate200),
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.brand600,
              size: 22,
            ),
          ),
          title: Text(
            tarea.materia.isEmpty ? 'Tarea analizada' : tarea.materia,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${tarea.nombreHijo} · ${_formatearFecha(tarea.fechaCreacion)}',
              style: const TextStyle(
                color: AppColors.slate500,
                fontSize: 12,
              ),
            ),
          ),
          trailing: IconButton(
            tooltip: 'Eliminar del historial',
            onPressed: () => _eliminar(tarea),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.slate400,
          ),
          children: <Widget>[
            if (tarea.temaDetectado.isNotEmpty)
              _buildDetalle(
                icon: Icons.lightbulb_outline,
                titulo: 'Tema detectado',
                texto: tarea.temaDetectado,
              ),
            if (tarea.metodoSep.isNotEmpty)
              _buildDetalle(
                icon: Icons.alt_route,
                titulo: 'Método SEP',
                texto: tarea.metodoSep,
              ),
            if (tarea.preguntasGuia.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              const Text(
                'Preguntas guía',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              for (final pregunta in tarea.preguntasGuia)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: AppColors.brand600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pregunta,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetalle({
    required IconData icon,
    required String titulo,
    required String texto,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.brand600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final mes = meses[fecha.month - 1];
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day} $mes ${fecha.year} · $hora:$minuto';
  }
}
