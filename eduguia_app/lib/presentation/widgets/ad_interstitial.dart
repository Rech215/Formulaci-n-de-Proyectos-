import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Anuncio intersticial simulado que se muestra a los usuarios gratuitos
/// después de cada escaneo. Devuelve `true` si el usuario pidió ver Premium.
Future<bool> showAdInterstitial(BuildContext context) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const _AdInterstitialDialog(),
  );
  return resultado ?? false;
}

class _AdInterstitialDialog extends StatefulWidget {
  const _AdInterstitialDialog();

  @override
  State<_AdInterstitialDialog> createState() => _AdInterstitialDialogState();
}

class _AdInterstitialDialogState extends State<_AdInterstitialDialog> {
  int _segundos = 3;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  Future<void> _iniciarCuentaRegresiva() async {
    while (mounted && _segundos > 0) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _segundos--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PUBLICIDAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _segundos > 0 ? 'Cierra en $_segundos s' : 'Listo',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.brand600, AppColors.brand400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.menu_book_rounded, color: Colors.white, size: 38),
                  SizedBox(height: 16),
                  Text(
                    'Aprender puede ser divertido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Espacio reservado para un patrocinador. '
                    'Con Premium navegas sin anuncios.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _segundos > 0
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  _segundos > 0
                      ? 'Espera $_segundos s'
                      : 'Continuar al resultado',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Quitar anuncios con Premium',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
