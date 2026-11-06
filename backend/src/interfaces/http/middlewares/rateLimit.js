import rateLimit from 'express-rate-limit';

/**
 * Límites básicos de abuso. No sustituyen al límite de negocio de 5 tareas:
 * solo protegen la API de ráfagas automatizadas.
 */
export function crearRateLimits() {
  const global = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: {
      error: {
        code: 'DEMASIADAS_SOLICITUDES',
        message: 'Demasiadas solicitudes. Intenta de nuevo más tarde.',
        details: null,
      },
    },
  });

  const auth = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 30,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: {
      error: {
        code: 'DEMASIADOS_INTENTOS',
        message: 'Demasiados intentos de acceso. Espera unos minutos.',
        details: null,
      },
    },
  });

  const analisis = rateLimit({
    windowMs: 60 * 1000,
    limit: 10,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: {
      error: {
        code: 'DEMASIADOS_ANALISIS',
        message: 'Estás analizando tareas muy rápido. Espera un momento.',
        details: null,
      },
    },
  });

  return { global, auth, analisis };
}
