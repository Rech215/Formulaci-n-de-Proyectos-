import { AppError } from '../../domain/errors.js';

/**
 * Valida el estado de la suscripción contra la API REST de RevenueCat.
 * RevenueCat, a su vez, valida la compra con App Store / Google Play.
 */
export function crearRevenueCatClient({
  secretKey,
  entitlementId,
  fetchImpl = fetch,
}) {
  return {
    get configurado() {
      return Boolean(secretKey);
    },

    async obtenerEntitlement(appUserId) {
      if (!secretKey) {
        throw new AppError(
          'RevenueCat no está configurado en el servidor.',
          { status: 503, code: 'REVENUECAT_NO_CONFIGURADO' },
        );
      }

      const url = `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`;
      let respuesta;
      try {
        respuesta = await fetchImpl(url, {
          headers: {
            Authorization: `Bearer ${secretKey}`,
            'Content-Type': 'application/json',
          },
          signal: AbortSignal.timeout(10000),
        });
      } catch {
        throw new AppError(
          'No pudimos validar la compra con RevenueCat. Intenta más tarde.',
          { status: 503, code: 'REVENUECAT_NO_DISPONIBLE' },
        );
      }

      if (respuesta.status === 404) {
        return { activo: false, expira: null };
      }
      if (!respuesta.ok) {
        throw new AppError(
          'RevenueCat rechazó la validación de la suscripción.',
          { status: 502, code: 'REVENUECAT_ERROR' },
        );
      }

      const datos = await respuesta.json();
      const entitlement = datos?.subscriber?.entitlements?.[entitlementId];
      if (!entitlement) {
        return { activo: false, expira: null };
      }

      const expira = entitlement.expires_date ?? null;
      const activo = !expira || new Date(expira) > new Date();

      return { activo, expira };
    },
  };
}
