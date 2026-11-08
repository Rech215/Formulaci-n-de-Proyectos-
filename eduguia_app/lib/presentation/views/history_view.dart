import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/historial_repository.dart';
import '../../injection.dart';
import '../state/analysis_provider.dart';
import '../state/session_provider.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text(
          'Se eliminarán todas las tareas guardadas en este dispositivo. '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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

  void _abrir(Tarea tarea) {
    context.read<AnalysisProvider>().mostrarTarea(tarea);
    context.go('/result');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.brand600,
      onRefresh: () async {
        final padreId = _padreId;
        if (padreId != null) await _cargar(padreId);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildEncabezado(),
                  const SizedBox(height: 20),
                  if (_cargando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brand600,
                        ),
                      ),
                    )
                  else if (_error != null)
                    _buildError()
                  else if (_tareas.isEmpty)
                    _buildVacio()
                  else
                    for (final tarea in _tareas)
                      _TarjetaHistorial(
                        tarea: tarea,
                        onTap: () => _abrir(tarea),
                        onEliminar: () => _eliminar(tarea),
                      ),
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
          'Abre cualquier tarea para repasar el método SEP y las preguntas '
          'guía. Solo se guarda en este dispositivo.',
          style: TextStyle(
            color: AppColors.slate500,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (_tareas.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _limpiar,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Limpiar historial'),
              style: TextButton.styleFrom(foregroundColor: AppColors.red600),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.brand50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_edu_outlined,
              size: 40,
              color: AppColors.brand600,
            ),
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
            'Cuando analices una tarea aparecerá aquí para que puedas '
            'repasar las preguntas guía con tu hijo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/escanear'),
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: const Text('Escanear una tarea'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaHistorial extends StatelessWidget {
  const _TarjetaHistorial({
    required this.tarea,
    required this.onTap,
    required this.onEliminar,
  });

  final Tarea tarea;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.brand50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.brand600,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tarea.materia.isEmpty
                            ? 'Tarea analizada'
                            : tarea.materia,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tarea.temaDetectado.isEmpty
                            ? tarea.nombreHijo
                            : '${tarea.nombreHijo} · ${tarea.temaDetectado}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatearFecha(tarea.fechaCreacion),
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar del historial',
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.slate400,
                ),
              ],
            ),
          ),
        ),
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
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year} · '
        '$hora:$minuto';
  }
}
