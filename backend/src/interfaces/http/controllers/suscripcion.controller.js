import { AppError } from '../../../domain/errors.js';

export function crearSuscripcionController({
  suscripcionService,
  revenueCatClient,
}) {
  function appUserIdDe(padre) {
    return padre.revenueCatAppUserId ?? padre._id.toString();
  }

  return {
    async obtener(req, res) {
      const suscripcion = await suscripcionService.obtener(req.padre._id);
      return res.json({ suscripcion });
    },

    async validar(req, res) {
      if (!revenueCatClient.configurado) {
        throw new AppError(
          'RevenueCat no está configurado en el servidor. '
          + 'No es posible validar la compra.',
          { status: 503, code: 'REVENUECAT_NO_CONFIGURADO' },
        );
      }

      const appUserId = appUserIdDe(req.padre);
      const { activo, expira } =
        await revenueCatClient.obtenerEntitlement(appUserId);

      const suscripcion = await suscripcionService.aplicarEstadoRevenueCat({
        padreId: req.padre._id,
        appUserId,
        activo,
        fechaRenovacion: expira,
      });

      return res.json({ suscripcion, validado: true });
    },

    async cancelar(req, res) {
      const appUserId = appUserIdDe(req.padre);
      const suscripcion = await suscripcionService.aplicarEstadoRevenueCat({
        padreId: req.padre._id,
        appUserId,
        activo: false,
        fechaRenovacion: null,
      });

      return res.json({ suscripcion });
    },
  };
}
