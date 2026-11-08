import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/repositories/historial_repository.dart';
import '../../domain/services/image_editor_service.dart';
import '../../injection.dart';
import '../state/analysis_provider.dart';
import '../state/session_provider.dart';
import '../widgets/ad_interstitial.dart';
import '../widgets/error_feedback.dart';
import '../widgets/shimmer_loading.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final padre = context.read<SessionProvider>().padre;
    if (padre != null && padre.hijos.isNotEmpty) {
      _hijoSeleccionado = padre.hijos.first.nombre;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hijoSeleccionado.isNotEmpty) return;
    final padre = context.read<SessionProvider>().padre;
    if (padre != null && padre.hijos.isNotEmpty) {
      _hijoSeleccionado = padre.hijos.first.nombre;
    }
  }

  Future<XFile?> _capturarYRecortar(ImageSource source) async {
    final foto = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (foto == null) return null;

    final recortada = await getIt<ImageEditorService>().recortar(
      sourcePath: foto.path,
    );
    return XFile(recortada ?? foto.path);
  }

  Future<void> _seleccionar(ImageSource source) async {
    try {
      final foto = await _capturarYRecortar(source);
      if (foto == null || !mounted) return;
      setState(() {
        _imagen = foto;
        _errorPicker = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorPicker = source == ImageSource.camera
            ? 'No se pudo acceder a la cámara. Verifica los permisos.'
            : 'No se pudo acceder a la galería. Verifica los permisos.';
      });
    }
  }

  Future<void> _analizar() async {
    if (_isLoading) return;

    final session = context.read<SessionProvider>();
    final analysis = context.read<AnalysisProvider>();
    final padre = session.padre;
    if (padre == null || _imagen == null) return;

    setState(() => _isLoading = true);

    try {
      await analysis.analizarTarea(
        padreId: padre.id,
        imagenPath: _imagen!.path,
        nombreHijo: _hijoSeleccionado,
      );

      if (!mounted) return;

      if (analysis.estado == EstadoAnalisis.error) {
        ErrorFeedback.show(context, analysis.errorExcepcion);
        return;
      }

      final tarea = analysis.tareaActual;
      if (tarea == null) return;

      await getIt<HistorialRepository>().guardar(padre.id, tarea);
      await session.recargar();

      if (!mounted) return;

      if (session.errorExcepcion != null) {
        ErrorFeedback.show(context, session.errorExcepcion);
      }

      if (!session.esPremium) {
        final quierePremium = await showAdInterstitial(context);
        if (!mounted) return;
        if (quierePremium) {
          context.go('/premium');
          return;
        }
      }

      context.go('/resultado');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return Consumer2<AnalysisProvider, SessionProvider>(
      builder: (context, analysis, session, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: <Widget>[
                    _buildEncabezado(session),
                    const SizedBox(height: 20),
                    if (analysis.estado == EstadoAnalisis.analizando)
                      _buildAnalizando()
                    else if (analysis.estado == EstadoAnalisis.error)
                      _buildError(analysis)
                    else if (_imagen == null)
                      _buildEstadoVacio()
                    else
                      _buildPreview(session),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEncabezado(SessionProvider session) {
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
          'Enfoca la tarea completa',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: session.esPremium ? AppColors.brand50 : AppColors.yellow100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                session.esPremium
                    ? Icons.all_inclusive
                    : Icons.campaign_outlined,
                size: 16,
                color: session.esPremium
                    ? AppColors.brand600
                    : AppColors.yellow600,
              ),
              const SizedBox(width: 6),
              Text(
                session.esPremium
                    ? 'Escaneos ilimitados sin anuncios'
                    : 'Escaneos gratis · con anuncio',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: session.esPremium
                      ? AppColors.brand700
                      : AppColors.yellow600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVacio() {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.brand600, AppColors.brand400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.brand500.withAlpha(77),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Toma una foto de la tarea',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Procura buena luz, captura toda la instrucción y evita '
                'sombras. Después podrás recortar la imagen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.slate500,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _seleccionar(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Abrir cámara'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _seleccionar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Elegir de la galería'),
                ),
              ),
            ],
          ),
        ),
        if (_errorPicker != null) ...<Widget>[
          const SizedBox(height: 12),
          _MensajeError(texto: _errorPicker!),
        ],
      ],
    );
  }

  Widget _buildPreview(SessionProvider session) {
    final hijos = session.padre?.hijos ?? const [];

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 420),
            color: AppColors.slate100,
            child: Image.file(
              File(_imagen!.path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.slate400,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
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
                        label: Text(hijo.nombre),
                        selected: _hijoSeleccionado == hijo.nombre,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _hijoSeleccionado = hijo.nombre);
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          )
        else if (hijos.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.person_outline,
                  color: AppColors.brand600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarea de ${hijos.first.nombre} · '
                    '${hijos.first.gradoEscolar}',
                    style: const TextStyle(
                      color: AppColors.brand700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isLoading ? null : () => setState(() => _imagen = null),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Cambiar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _analizar,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 20),
                label: Text(_isLoading ? 'Analizando...' : 'Analizar tarea'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalizando() {
    return Column(
      children: <Widget>[
        if (_imagen != null)
          Opacity(
            opacity: 0.35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 220),
                color: AppColors.slate100,
                child: Image.file(
                  File(_imagen!.path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
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

  Widget _buildError(AnalysisProvider analysis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.red500.withAlpha(77)),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.red600, size: 42),
          const SizedBox(height: 14),
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _reiniciar,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Intentar de nuevo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber, color: AppColors.red600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: AppColors.red600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
