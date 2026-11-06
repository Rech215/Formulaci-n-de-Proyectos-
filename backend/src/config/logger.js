import pino from 'pino';
import { env } from './env.js';

/**
 * Logger centralizado.
 *
 * Regla de privacidad: nunca se registran cuerpos de petición, buffers,
 * imágenes, tokens ni correos electrónicos completos. pino redacta las
 * cabeceras sensibles.
 */
export const logger = pino({
  level: env.NODE_ENV === 'test' ? 'silent' : 'info',
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'res.headers["set-cookie"]',
      '*.password',
      '*.passwordHash',
      '*.token',
    ],
    censor: '[redactado]',
  },
  base: {
    servicio: 'eduguia-api',
    entorno: env.NODE_ENV,
  },
});
