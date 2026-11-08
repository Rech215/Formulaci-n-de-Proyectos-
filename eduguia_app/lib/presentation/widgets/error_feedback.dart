import 'package:flutter/material.dart';

import '../../core/errors/domain_exception.dart';
import '../../core/errors/network_exceptions.dart';
import '../../core/theme/app_colors.dart';

/// Presenta mensajes de error amigables sin cerrar la pantalla actual.
abstract final class ErrorFeedback {
  static void show(BuildContext context, DomainException? error) {
    if (error == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _color(error),
        content: Row(
          children: <Widget>[
            Icon(_icon(error), color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_titulo(error)}: ${error.message}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  static Future<void> showAlert(BuildContext context, DomainException? error) {
    if (error == null) return Future<void>.value();

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(_icon(error), color: _color(error), size: 36),
        title: Text(_titulo(error)),
        content: Text(error.message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  static String _titulo(DomainException error) {
    if (error is NetworkException) return 'Sin conexión';
    if (error is TimeoutException) return 'La IA tardó demasiado';
    if (error is ServerException) return 'Error del servidor';
    return 'Algo salió mal';
  }

  static IconData _icon(DomainException error) {
    if (error is NetworkException) return Icons.wifi_off_rounded;
    if (error is TimeoutException) return Icons.hourglass_bottom_rounded;
    if (error is ServerException) return Icons.cloud_off_rounded;
    return Icons.error_outline_rounded;
  }

  static Color _color(DomainException error) {
    if (error is NetworkException) return AppColors.orange600;
    if (error is TimeoutException) return AppColors.yellow600;
    if (error is ServerException) return AppColors.red600;
    return AppColors.slate700;
  }
}
