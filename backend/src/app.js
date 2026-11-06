import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import pinoHttp from 'pino-http';

import { crearErrorHandler } from './interfaces/http/middlewares/errorHandler.js';
import { crearRateLimits } from './interfaces/http/middlewares/rateLimit.js';
import { crearRutas } from './interfaces/http/routes/index.js';

export function crearApp({
  contenedor,
  logger,
  esProduccion,
  corsOrigin,
  maxImageMb,
  webhookSecret,
  rateLimits,
}) {
  const app = express();
  const limits = rateLimits ?? crearRateLimits();

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({
    origin: corsOrigin === '*'
      ? '*'
      : corsOrigin.split(',').map((origen) => origen.trim()),
  }));
  app.use(pinoHttp({
    logger,
    autoLogging: {
      ignore: (req) => req.url === '/api/salud',
    },
    serializers: {
      req(req) {
        return {
          id: req.id,
          method: req.method,
          url: req.url,
        };
      },
      res(res) {
        return { statusCode: res.statusCode };
      },
    },
  }));
  app.use(express.json({ limit: '1mb' }));

  app.use('/api', limits.global);

  app.get('/api/salud', (_req, res) => {
    res.json({
      estado: 'ok',
      servicio: 'eduguia-api',
      hora: new Date().toISOString(),
    });
  });

  app.use('/api', crearRutas({
    contenedor,
    limits,
    maxImageMb,
    webhookSecret,
  }));

  app.use((_req, res) => {
    res.status(404).json({
      error: {
        code: 'NO_ENCONTRADO',
        message: 'La ruta solicitada no existe.',
        details: null,
      },
    });
  });

  app.use(crearErrorHandler({ logger, esProduccion }));

  return app;
}
