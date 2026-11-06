import express from 'express';

import { crearSuscripcionController } from '../controllers/suscripcion.controller.js';
import { crearRevenueCatWebhookController } from '../controllers/revenuecatWebhook.controller.js';
import { asyncHandler } from '../middlewares/asyncHandler.js';

export function crearSuscripcionRoutes({
  suscripcionService,
  revenueCatClient,
}) {
  const router = express.Router();
  const controller = crearSuscripcionController({
    suscripcionService,
    revenueCatClient,
  });

  router.get('/', asyncHandler(controller.obtener));
  router.post('/validar', asyncHandler(controller.validar));
  router.post('/cancelar', asyncHandler(controller.cancelar));

  return router;
}

export function crearRevenueCatWebhookRoutes({
  suscripcionService,
  padreRepository,
  webhookSecret,
}) {
  const router = express.Router();
  const controller = crearRevenueCatWebhookController({
    suscripcionService,
    padreRepository,
    webhookSecret,
  });

  router.post('/revenuecat', asyncHandler(controller.recibir));

  return router;
}
