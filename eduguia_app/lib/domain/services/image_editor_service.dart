/// Contrato del editor de imágenes previo al análisis.
///
/// La implementación concreta usa `image_cropper` y se inyecta desde la capa
/// de datos, de modo que la presentación no dependa del plugin.
abstract class ImageEditorService {
  /// Abre el editor visual y devuelve la ruta de la imagen recortada.
  ///
  /// Devuelve `null` si el usuario cancela el recorte.
  Future<String?> recortar({required String sourcePath});
}
