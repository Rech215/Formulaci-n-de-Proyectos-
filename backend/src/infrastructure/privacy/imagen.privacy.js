import sharp from 'sharp';
import { AppError } from '../../domain/errors.js';

export const MIME_PERMITIDOS = Object.freeze([
  'image/jpeg',
  'image/png',
  'image/webp',
]);

const PIXELES_MAXIMOS = 40_000_000;

/**
 * Re-encodea la imagen en memoria para:
 *  1. Eliminar metadatos EXIF (GPS, modelo del dispositivo, fecha, etc.).
 *  2. Corregir la orientación sin conservar el EXIF.
 *  3. Reducir el tamaño antes de enviarla a la IA.
 *
 * Nunca escribe en disco. Devuelve un buffer nuevo; el buffer original debe
 * ser sobrescrito por el controlador.
 */
export async function sanearImagen(buffer, mimeType) {
  if (!MIME_PERMITIDOS.includes(mimeType)) {
    throw new AppError(
      'Formato de imagen no soportado. Usa JPG, PNG o WEBP.',
      { status: 415, code: 'FORMATO_IMAGEN_INVALIDO' },
    );
  }

  try {
    const salida = await sharp(buffer, {
      failOn: 'none',
      limitInputPixels: PIXELES_MAXIMOS,
    })
      .rotate()
      .resize({
        width: 1800,
        height: 1800,
        fit: 'inside',
        withoutEnlargement: true,
      })
      .jpeg({ quality: 82, mozjpeg: true })
      .toBuffer();

    return { buffer: salida, mimeType: 'image/jpeg' };
  } catch {
    throw new AppError('No pudimos leer la imagen. Intenta con otra foto.', {
      status: 422,
      code: 'IMAGEN_ILEGIBLE',
    });
  }
}
