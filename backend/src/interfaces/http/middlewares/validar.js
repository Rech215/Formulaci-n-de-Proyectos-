import { AppError } from '../../../domain/errors.js';

/**
 * Valida y normaliza una parte de la petición con un esquema Zod.
 *
 * @param {import('zod').ZodTypeAny} schema
 * @param {'body'|'query'|'params'} origen
 */
export function validar(schema, origen = 'body') {
  return function validarSolicitud(req, _res, next) {
    const resultado = schema.safeParse(req[origen] ?? {});

    if (!resultado.success) {
      const details = resultado.error.issues.map((issue) => ({
        campo: issue.path.join('.'),
        mensaje: issue.message,
      }));
      return next(
        new AppError('La solicitud contiene datos inválidos.', {
          status: 422,
          code: 'DATOS_INVALIDOS',
          details,
        }),
      );
    }

    req[origen] = resultado.data;
    return next();
  };
}
