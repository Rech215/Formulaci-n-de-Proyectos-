import multer from 'multer';
import { AppError } from '../../../domain/errors.js';

function esErrorDuplicado(error) {
  return error?.code === 11000;
}

function esErrorValidacionMongoose(error) {
  return error?.name === 'ValidationError';
}

/**
 * Respuesta de error uniforme para Flutter.
 *
 * Formato:
 * { "error": { "code": "...", "message": "...", "details": [...] } }
 *
 * Nunca se registran cuerpos, imágenes, tokens ni datos personales.
 */
export function crearErrorHandler({ logger, esProduccion }) {
  return function manejarError(error, req, res, _next) {
    if (error instanceof AppError) {
      return res.status(error.status).json({
        error: {
          code: error.code,
          message: error.message,
          details: error.details ?? null,
        },
      });
    }

    if (error instanceof multer.MulterError) {
      const esTamano = error.code === 'LIMIT_FILE_SIZE';
      return res.status(esTamano ? 413 : 422).json({
        error: {
          code: esTamano ? 'IMAGEN_DEMASIADO_GRANDE' : 'IMAGEN_INVALIDA',
          message: esTamano
            ? 'La imagen excede el tamaño máximo permitido.'
            : 'No pudimos recibir la imagen adjunta.',
          details: null,
        },
      });
    }

    if (esErrorDuplicado(error)) {
      return res.status(409).json({
        error: {
          code: 'REGISTRO_DUPLICADO',
          message: 'Ya existe un registro con esos datos.',
          details: null,
        },
      });
    }

    if (esErrorValidacionMongoose(error)) {
      return res.status(422).json({
        error: {
          code: 'DATOS_INVALIDOS',
          message: 'Los datos enviados no cumplen el formato esperado.',
          details: null,
        },
      });
    }

    logger.error(
      {
        error: error?.message,
        ruta: req.originalUrl,
        metodo: req.method,
      },
      'Error no controlado en la API',
    );

    return res.status(500).json({
      error: {
        code: 'ERROR_INTERNO',
        message: esProduccion
          ? 'Ocurrió un error interno. Intenta de nuevo.'
          : (error?.message ?? 'Ocurrió un error interno.'),
        details: null,
      },
    });
  };
}
