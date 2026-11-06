import express from 'express';

import { crearTareasController } from '../controllers/tareas.controller.js';
import { asyncHandler } from '../middlewares/asyncHandler.js';
import { crearAutenticacion } from '../middlewares/autenticacion.js';
import { crearAuthRoutes } from './auth.routes.js';
import { crearHijosRoutes } from './hijos.routes.js';
import {
  crearRevenueCatWebhookRoutes,
  crearSuscripcionRoutes,
} from './suscripcion.routes.js';
import { crearTareasRoutes } from './tareas.routes.js';

export function crearRutas({ contenedor, limits, maxImageMb, webhookSecret }) {
  const router = express.Router();
  const autenticacion = crearAutenticacion({
    authService: contenedor.authService,
    padreRepository: contenedor.padreRepository,
  });

  router.use('/auth', crearAuthRoutes({
    authService: contenedor.authService,
    padreRepository: contenedor.padreRepository,
    hijoRepository: contenedor.hijoRepository,
    limits,
  }));

  router.use('/webhooks', crearRevenueCatWebhookRoutes({
    suscripcionService: contenedor.suscripcionService,
    padreRepository: contenedor.padreRepository,
    webhookSecret,
  }));

  router.use('/hijos', autenticacion, crearHijosRoutes({
    padreRepository: contenedor.padreRepository,
    hijoRepository: contenedor.hijoRepository,
  }));

  const tareasController = crearTareasController({
    tareaService: contenedor.tareaService,
    suscripcionService: contenedor.suscripcionService,
    hijoRepository: contenedor.hijoRepository,
    consultaRepository: contenedor.consultaRepository,
  });

  router.get(
    '/resumen',
    autenticacion,
    asyncHandler(tareasController.resumen),
  );

  router.use('/tareas', autenticacion, crearTareasRoutes({
    tareaService: contenedor.tareaService,
    suscripcionService: contenedor.suscripcionService,
    hijoRepository: contenedor.hijoRepository,
    consultaRepository: contenedor.consultaRepository,
    limits,
    maxImageMb,
  }));

  router.use('/suscripcion', autenticacion, crearSuscripcionRoutes({
    suscripcionService: contenedor.suscripcionService,
    revenueCatClient: contenedor.revenueCatClient,
  }));

  return router;
}
