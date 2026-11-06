import { timingSafeEqual } from 'node:crypto';

import { NoAutorizadoError } from '../../../domain/errors.js';

const EVENTOS_ACTIVOS = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'PRODUCT_CHANGE',
  'NON_RENEWING_PURCHASE',
  'SUBSCRIPTION_EXTENDED',
]);

const EVENTOS_INACTIVOS = new Set([
  'EXPIRATION',
]);

function coincideSecreto(recibido, esperado) {
  if (!recibido || !esperado) return false;
  const a = Buffer.from(String(recibido));
  const b = Buffer.from(String(esperado));
  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

export function crearRevenueCatWebhookController({
  suscripcionService,
  padreRepository,
  webhookSecret,
}) {
  return {
    async recibir(req, res) {
      if (!webhookSecret) {
        throw new NoAutorizadoError('El webhook de RevenueCat no está configurado.');
      }

      const secreto =
        req.headers['x-webhook-secret']
        ?? (req.headers.authorization ?? '').replace(/^Bearer\s+/i, '');

      if (!coincideSecreto(secreto, webhookSecret)) {
        throw new NoAutorizadoError('Secreto de webhook inválido.');
      }

      const evento = req.body?.event ?? {};
      const appUserId = evento.app_user_id;
      const tipo = evento.type;

      if (!appUserId || (!EVENTOS_ACTIVOS.has(tipo) && !EVENTOS_INACTIVOS.has(tipo))) {
        return res.json({ recibido: true, ignorado: true });
      }

      let padre = await padreRepository.buscarPorRevenueCatAppUserId(appUserId);

      if (!padre && /^[a-f0-9]{24}$/i.test(appUserId)) {
        padre = await padreRepository.buscarPorId(appUserId);
      }

      if (!padre) {
        return res.json({ recibido: true, ignorado: true });
      }

      const activo = EVENTOS_ACTIVOS.has(tipo);
      const expira = evento.expiration_at_ms
        ? new Date(Number(evento.expiration_at_ms))
        : null;

      await suscripcionService.aplicarEstadoRevenueCat({
        padreId: padre._id,
        appUserId,
        activo,
        fechaRenovacion: expira,
      });

      return res.json({ recibido: true });
    },
  };
}
