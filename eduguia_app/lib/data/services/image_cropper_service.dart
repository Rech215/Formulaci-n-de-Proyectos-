import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/services/image_editor_service.dart';

/// Editor visual basado en `image_cropper` con la identidad de EduGuía.
class ImageCropperService implements ImageEditorService {
  @override
  Future<String?> recortar({required String sourcePath}) async {
    final resultado = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: 2048,
      maxHeight: 2048,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Recorta la tarea',
          toolbarColor: AppColors.slate900,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppColors.slate900,
          statusBarLight: false,
          navBarLight: false,
          activeControlsWidgetColor: AppColors.brand500,
          cropFrameColor: AppColors.brand400,
          cropGridColor: AppColors.brand300,
          lockAspectRatio: false,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Recorta la tarea',
          cancelButtonTitle: 'Cancelar',
          doneButtonTitle: 'Listo',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return resultado?.path;
  }
}
