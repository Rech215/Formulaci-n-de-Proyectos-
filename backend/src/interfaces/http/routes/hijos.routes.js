import express from 'express';

import {
  hijoSchema,
  hijoNombreQuerySchema,
  hijoParametroSchema,
} from '../../../application/validators.js';
import { crearHijosController } from '../controllers/hijos.controller.js';
import { asyncHandler } from '../middlewares/asyncHandler.js';
import { validar } from '../middlewares/validar.js';

export function crearHijosRoutes({ padreRepository, hijoRepository }) {
  const router = express.Router();
  const controller = crearHijosController({
    padreRepository,
    hijoRepository,
  });

  router.get('/', asyncHandler(controller.listar));

  router.post(
    '/',
    validar(hijoSchema),
    asyncHandler(controller.crear),
  );

  router.delete(
    '/',
    validar(hijoNombreQuerySchema, 'query'),
    asyncHandler(controller.eliminar),
  );

  router.delete(
    '/:hijoId',
    validar(hijoParametroSchema, 'params'),
    asyncHandler(controller.eliminar),
  );

  return router;
}
