import express from 'express';

import { analizarTareaSchema } from '../../../application/validators.js';
import { crearTareasController } from '../controllers/tareas.controller.js';
import { asyncHandler } from '../middlewares/asyncHandler.js';
import { crearUploadImagen } from '../middlewares/upload.js';
import { validar } from '../middlewares/validar.js';

export function crearTareasRoutes({
  tareaService,
  suscripcionService,
  hijoRepository,
  consultaRepository,
  limits,
  maxImageMb,
}) {
  const router = express.Router();
  const controller = crearTareasController({
    tareaService,
    suscripcionService,
    hijoRepository,
    consultaRepository,
  });
  const upload = crearUploadImagen({ maxImageMb });

  router.post(
    '/analizar',
    limits.analisis,
    upload.single('imagen'),
    validar(analizarTareaSchema),
    asyncHandler(controller.analizar),
  );

  router.get('/', asyncHandler(controller.listar));

  router.get('/:tareaId', asyncHandler(controller.obtener));

  return router;
}
