import { crearAuthService } from './application/services/auth.service.js';
import { crearSuscripcionService } from './application/services/suscripcion.service.js';
import { crearTareaService } from './application/services/tarea.service.js';
import { crearProveedorGemini } from './infrastructure/ai/geminiVision.provider.js';
import {
  construirPromptUsuario,
  construirSystemPrompt,
} from './infrastructure/ai/prompts/asesorPedagogico.prompt.js';
import { parsearResultadoIA } from './infrastructure/ai/resultadoAnalisis.validator.js';
import { crearConsultaRepository } from './infrastructure/persistence/repositories/consulta.repository.js';
import { crearHijoRepository } from './infrastructure/persistence/repositories/hijo.repository.js';
import { crearPadreRepository } from './infrastructure/persistence/repositories/padre.repository.js';
import { crearSuscripcionRepository } from './infrastructure/persistence/repositories/suscripcion.repository.js';
import { crearUsoRepository } from './infrastructure/persistence/repositories/uso.repository.js';
import { sanearImagen } from './infrastructure/privacy/imagen.privacy.js';
import { crearRevenueCatClient } from './infrastructure/revenuecat/revenuecat.client.js';

export function crearContenedor({ env, logger }) {
  const padreRepository = crearPadreRepository();
  const hijoRepository = crearHijoRepository();
  const suscripcionRepository = crearSuscripcionRepository();
  const usoRepository = crearUsoRepository();
  const consultaRepository = crearConsultaRepository();

  const authService = crearAuthService({
    padreRepository,
    hijoRepository,
    suscripcionRepository,
    jwtSecret: env.JWT_SECRET,
    jwtExpiresIn: env.JWT_EXPIRES_IN,
  });

  const suscripcionService = crearSuscripcionService({
    padreRepository,
    suscripcionRepository,
    usoRepository,
  });

  const proveedorIA = crearProveedorGemini({
    apiKey: env.GEMINI_API_KEY,
    model: env.GEMINI_MODEL,
    timeoutMs: env.AI_TIMEOUT_MS,
    logger,
  });

  const tareaService = crearTareaService({
    suscripcionService,
    consultaRepository,
    proveedorIA,
    construirSystemPrompt,
    construirPromptUsuario,
    parsearResultadoIA,
    sanearImagen,
  });

  const revenueCatClient = crearRevenueCatClient({
    secretKey: env.REVENUECAT_SECRET_KEY,
    entitlementId: env.REVENUECAT_ENTITLEMENT_ID,
  });

  return {
    padreRepository,
    hijoRepository,
    suscripcionRepository,
    usoRepository,
    consultaRepository,
    authService,
    suscripcionService,
    tareaService,
    proveedorIA,
    revenueCatClient,
  };
}
