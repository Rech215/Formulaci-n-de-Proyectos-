import express from 'express';

import { loginSchema, registroSchema } from '../../../application/validators.js';
import { crearAuthController } from '../controllers/auth.controller.js';
import { asyncHandler } from '../middlewares/asyncHandler.js';
import { crearAutenticacion } from '../middlewares/autenticacion.js';
import { validar } from '../middlewares/validar.js';

export function crearAuthRoutes({
  authService,
  padreRepository,
  hijoRepository,
  limits,
}) {
  const router = express.Router();
  const controller = crearAuthController({ authService, hijoRepository });
  const autenticacion = crearAutenticacion({ authService, padreRepository });

  router.post(
    '/registro',
    limits.auth,
    validar(registroSchema),
    asyncHandler(controller.registrar),
  );

  router.post(
    '/login',
    limits.auth,
    validar(loginSchema),
    asyncHandler(controller.iniciarSesion),
  );

  router.get(
    '/perfil',
    autenticacion,
    asyncHandler(controller.perfil),
  );

  return router;
}
