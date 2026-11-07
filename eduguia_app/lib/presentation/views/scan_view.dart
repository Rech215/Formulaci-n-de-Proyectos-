import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/repositories/historial_repository.dart';
import '../../domain/repositories/local_usage_repository.dart';
import '../../domain/services/image_editor_service.dart';
import '../../injection.dart';
import '../state/analysis_provider.dart';
import '../state/session_provider.dart';
import '../widgets/error_feedback.dart';
import '../widgets/shimmer_loading.dart';

/// Pantalla de escaneo de tareas.
///
/// Permite al padre tomar una foto o seleccionar de la galería,
/// previsualizarla y enviarla al análisis simulado de IA.
class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imagen;
  String? _errorPicker;
  String _hijoSeleccionado = '';
  int? _consultasRestantes;
  String? _padreIdConsultas;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionProvider>();
    if (session.padre != null && session.padre!.hijos.isNotEmpty) {
      _hijoSeleccionado = session.padre!.hijos.first.nombre;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final padre = context.watch<SessionProvider>().padre;
    if (padre != null && padre.id != _padreIdConsultas) {
      _padreIdConsultas = padre.id;
      _cargarConsultas(padre.id);
    }
  }

  bool get _bloqueado {
    if (context.read<SessionProvider>().suscripcion?.esPremium ?? false) {
      return false;
    }
    return (_consultasRestantes ??
            LocalUsageRepository.consultasGratuitasIniciales) <=
        0;
  }

  Future<void> _cargarConsultas(String padreId) async {
    final restantes =
        await getIt<LocalUsageRepository>().obtenerRestantes(padreId);
    if (!mounted || _padreIdConsultas != padreId) return;
    setState(() => _consultasRestantes = restantes);
  }

  Future<bool> _verificarAcceso() async {
    final session = context.read<SessionProvider>();
    final padre = session.padre;

    if (padre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para escanear tareas.')),
      );
      return false;
    }

    if (session.suscripcion?.esPremium ?? false) return true;

    final restantes =
        await getIt<LocalUsageRepository>().obtenerRestantes(padre.id);
    if (!mounted) return false;
    setState(() => _consultasRestantes = restantes);

    if (restantes > 0) return true;

    _irAPaywall();
    return false;
  }

  void _irAPaywall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Usaste tus 5 consultas gratuitas. '
          'Pásate a Premium para seguir escaneando.',
        ),
      ),
    );
    context.go('/planes');
  }

  Future<XFile?> _capturarYRecortar(ImageSource source) async {
    final foto = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (foto == null) return null;

    final recortada = await getIt<ImageEditorService>().recortar(
      sourcePath: foto.path,
    );
    return XFile(recortada ?? foto.path);
  }

  Future<void> _tomarFoto() async {
    if (!await _verificarAcceso()) return;

    try {
      final foto = await _capturarYRecortar(ImageSource.camera);
      if (foto == null || !mounted) return;
      setState(() {
        _imagen = foto;
        _errorPicker = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorPicker = 'No se pudo acceder a la cámara. '
            'Verifica los permisos o usa la galería.';
      });
    }
  }

  Future<void> _abrirGaleria() async {
    if (!await _verificarAcceso()) return;

    try {
      final foto = await _capturarYRecortar(ImageSource.gallery);
      if (foto == null || !mounted) return;
      setState(() {
        _imagen = foto;
        _errorPicker = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorPicker = 'No se pudo acceder a la galería. '
            'Verifica los permisos.';
      });
    }
  }

  Future<void> _analizar() async {
    final session = context.read<SessionProvider>();
    final analysis = context.read<AnalysisProvider>();
    final padre = session.padre;
    if (padre == null || _imagen == null) return;

    if (!await _verificarAcceso()) return;

    await analysis.analizarTarea(
      padreId: padre.id,
      imagenPath: _imagen!.path,
      nombreHijo: _hijoSeleccionado,
    );

    if (analysis.estado == EstadoAnalisis.completado) {
      final tarea = analysis.tareaActual;
      if (tarea != null) {
        await getIt<HistorialRepository>().guardar(padre.id, tarea);
      }

      if (!(session.suscripcion?.esPremium ?? false)) {
        final restantes =
            await getIt<LocalUsageRepository>().consumir(padre.id);
        if (mounted) setState(() => _consultasRestantes = restantes);
      }

      await session.recargar();
    }

    if (!mounted) return;

    if (analysis.estado == EstadoAnalisis.error) {
      ErrorFeedback.show(context, analysis.errorExcepcion);
      return;
    }

    if (session.errorExcepcion != null) {
      ErrorFeedback.show(context, session.errorExcepcion);
    }
  }

  void _reiniciar() {
    context.read<AnalysisProvider>().reiniciar();
    setState(() {
      _imagen = null;
      _errorPicker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysis, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: <Widget>[
                  // ── Encabezado ────────────────────────────────────
                  _buildEncabezado(),
                  const SizedBox(height: 24),

                  // ── Contenido según estado ────────────────────────
                  if (analysis.estado == EstadoAnalisis.inactivo &&
                      _imagen == null)
                    _buildEstadoVacio()
                  else if (analysis.estado == EstadoAnalisis.inactivo &&
                      _imagen != null)
                    _buildPreview()
                  else if (analysis.estado == EstadoAnalisis.analizando)
                    _buildAnalizando()
                  else if (analysis.estado == EstadoAnalisis.completado)
                    _buildResultado(analysis)
                  else if (analysis.estado == EstadoAnalisis.error)
                    _buildError(analysis),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ENCABEZADO
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildEncabezado() {
    final session = context.watch<SessionProvider>();
    final suscripcion = session.suscripcion;
    final esPremium = suscripcion?.esPremium ?? false;
    final restantes = esPremium
        ? null
        : (_consultasRestantes ??
            suscripcion?.consultasRestantes ??
            LocalUsageRepository.consultasGratuitasIniciales);
    final bloqueado = !esPremium && (restantes ?? 0) <= 0;

    return Column(
      children: <Widget>[
        const Text(
          'ESCANEAR TAREA',
          style: TextStyle(
            color: AppColors.brand600,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Analiza la tarea de tu hijo',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        if (suscripcion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: esPremium
                  ? AppColors.brand50
                  : (bloqueado ? AppColors.red100 : AppColors.yellow100),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: esPremium
                    ? AppColors.brand200
                    : (bloqueado
                        ? AppColors.red500.withAlpha(77)
                        : AppColors.yellow600.withAlpha(77)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  esPremium
                      ? Icons.all_inclusive
                      : (bloqueado ? Icons.lock_outline : Icons.timer_outlined),
                  size: 16,
                  color: esPremium
                      ? AppColors.brand600
                      : (bloqueado ? AppColors.red600 : AppColors.yellow600),
                ),
                const SizedBox(width: 6),
                Text(
                  esPremium
                      ? 'Consultas ilimitadas'
                      : (bloqueado
                          ? 'Sin consultas gratuitas'
                          : 'Te quedan $restantes consultas gratuitas'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: esPremium
                        ? AppColors.brand700
                        : (bloqueado ? AppColors.red600 : AppColors.yellow600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADO VACÍO (sin imagen seleccionada)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildEstadoVacio() {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56),
          decoration: BoxDecoration(
            color: AppColors.brand50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.brand200,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.brand600, AppColors.brand400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.brand500.withAlpha(77),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Escanea la tarea de tu hijo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _bloqueado
                      ? 'Usaste tus 5 consultas gratuitas. '
                          'Pásate a Premium para seguir acompañando a tu hijo.'
                      : 'Toma una foto o selecciona una imagen de la galería\n'
                          'para comenzar el análisis.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (_bloqueado)
                FilledButton.icon(
                  onPressed: () => context.go('/planes'),
                  icon: const Icon(Icons.workspace_premium, size: 20),
                  label: const Text('Ver planes Premium'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _tomarFoto,
                      icon: const Icon(Icons.photo_camera, size: 20),
                      label: const Text('Cámara'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _abrirGaleria,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: const Text('Galería'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand700,
                        side: const BorderSide(color: AppColors.brand200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_errorPicker != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.red100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.warning_amber,
                    color: AppColors.red600, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorPicker!,
                    style: const TextStyle(
                      color: AppColors.red600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildTipsRapidos(),
      ],
    );
  }

  Widget _buildTipsRapidos() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.yellow600, size: 20),
              SizedBox(width: 8),
              Text(
                'Tips para una mejor foto',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final tip in <String>[
            'Asegúrate de que la hoja esté bien iluminada',
            'Evita sombras sobre el texto',
            'Captura toda la instrucción del ejercicio',
            'Si es un libro, mantén la página plana',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.check_circle,
                      color: AppColors.brand500, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: AppColors.slate600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PREVISUALIZACIÓN DE IMAGEN
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPreview() {
    final session = context.watch<SessionProvider>();
    final hijos = session.padre?.hijos ?? [];

    return Column(
      children: <Widget>[
        // ── Imagen ──────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.file(
              File(_imagen!.path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Container(
                height: 200,
                color: AppColors.slate100,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.broken_image_outlined,
                          size: 48, color: AppColors.slate400),
                      SizedBox(height: 8),
                      Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Selector de hijo ────────────────────────────────────────
        if (hijos.length > 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '¿De quién es la tarea?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final hijo in hijos)
                      ChoiceChip(
                        label: Text('${hijo.nombre} (${hijo.gradoEscolar})'),
                        selected: _hijoSeleccionado == hijo.nombre,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _hijoSeleccionado = hijo.nombre);
                          }
                        },
                        selectedColor: AppColors.brand100,
                        checkmarkColor: AppColors.brand700,
                      ),
                  ],
                ),
              ],
            ),
          )
        else if (hijos.length == 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.person, color: AppColors.brand600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tarea de ${hijos.first.nombre} · ${hijos.first.gradoEscolar}',
                  style: const TextStyle(
                    color: AppColors.brand700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // ── Botones de acción ───────────────────────────────────────
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _imagen = null);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Cambiar foto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate600,
                  side: const BorderSide(color: AppColors.slate200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _analizar,
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text('Analizar tarea'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADO: ANALIZANDO
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildAnalizando() {
    return Column(
      children: <Widget>[
        // Imagen con opacidad reducida
        if (_imagen != null)
          Opacity(
            opacity: 0.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 250),
                child: Image.file(
                  File(_imagen!.path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        const SizedBox(height: 28),

        const Text(
          'Analizando la tarea...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Identificando materia, método SEP\ny generando preguntas guía...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.slate500,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        const AnalysisLoadingSkeleton(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADO: RESULTADO EXITOSO
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildResultado(AnalysisProvider analysis) {
    final tarea = analysis.tareaActual;
    if (tarea == null) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        // ── Badge de éxito ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_circle, color: AppColors.green600, size: 18),
              SizedBox(width: 6),
              Text(
                'Análisis completado',
                style: TextStyle(
                  color: AppColors.green600,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Materia y Tema ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.brand100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_stories,
                        color: AppColors.brand600, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brand50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tarea.materia,
                            style: const TextStyle(
                              color: AppColors.brand700,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tarea.temaDetectado,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Método SEP ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        Icon(Icons.school_outlined,
                            color: AppColors.green600, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Método SEP detectado',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tarea.metodoSep,
                      style: const TextStyle(
                        color: AppColors.slate600,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Preguntas Guía ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.brand200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.chat_bubble_outline,
                      color: AppColors.brand600, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Preguntas guía para tu hijo',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Usa estas preguntas para acompañar a tu hijo. '
                'No le des la respuesta, guíalo.',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < tarea.preguntasGuia.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.brand100,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppColors.brand700,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            tarea.preguntasGuia[i],
                            style: const TextStyle(
                              color: AppColors.slate700,
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Regla de Oro ────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.yellow100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.yellow600.withAlpha(51)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.yellow600, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Regla de oro',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.slate900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Valida su intento y devuélvele una pregunta: '
                      '"¿Cómo podrías comprobarlo?". '
                      'Nunca le des el resultado final.',
                      style: TextStyle(
                        color: AppColors.slate700,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Botones post-análisis ───────────────────────────────────
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(Icons.document_scanner_outlined, size: 20),
                label: const Text('Escanear otra tarea'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => context.go('/inicio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate600,
                side: const BorderSide(color: AppColors.slate200),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Inicio'),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADO: ERROR
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildError(AnalysisProvider analysis) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.red100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.red500.withAlpha(77)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.red500.withAlpha(31),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(Icons.error_outline,
                    color: AppColors.red600, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'No pudimos analizar la tarea',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.error ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.slate600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: _reiniciar,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.red600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  if (!analysis.error!.contains('límite'))
                    TextButton(
                      onPressed: () => context.go('/inicio'),
                      child: const Text('Volver al inicio'),
                    )
                  else
                    FilledButton(
                      onPressed: () => context.go('/planes'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Ver planes Premium'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
