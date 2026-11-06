import multer from 'multer';
import { MIME_PERMITIDOS } from '../../../infrastructure/privacy/imagen.privacy.js';

/**
 * Almacenamiento en memoria: la imagen NUNCA se escribe en disco.
 *
 * El controlador se encarga de sobrescribir el buffer con ceros en el bloque
 * `finally`, incluso si la IA falla. Multer solo acepta imágenes JPEG, PNG o
 * WEBP con el límite configurado.
 */
export function crearUploadImagen({ maxImageMb }) {
  return multer({
    storage: multer.memoryStorage(),
    limits: {
      fileSize: Math.ceil(maxImageMb * 1024 * 1024),
      files: 1,
      fields: 6,
    },
    fileFilter(_req, file, callback) {
      if (!MIME_PERMITIDOS.includes(file.mimetype)) {
        const error = new multer.MulterError(
          'LIMIT_UNEXPECTED_FILE',
          file.fieldname,
        );
        error.message = 'Formato no permitido. Usa JPG, PNG o WEBP.';
        return callback(error);
      }
      return callback(null, true);
    },
  });
}
