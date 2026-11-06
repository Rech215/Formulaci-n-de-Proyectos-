import { SuscripcionModel } from '../mongoose/models/suscripcion.model.js';

export function crearSuscripcionRepository() {
  return {
    async obtenerOCrear(padreId) {
      return SuscripcionModel.findOneAndUpdate(
        { padreId },
        {
          $setOnInsert: {
            padreId,
            plan: 'GRATUITO',
            estado: 'ACTIVA',
            proveedor: 'NONE',
            fechaInicio: new Date(),
          },
        },
        { new: true, upsert: true, setDefaultsOnInsert: true },
      );
    },

    obtenerPorPadre(padreId) {
      return SuscripcionModel.findOne({ padreId });
    },

    buscarPorRevenueCatAppUserId(appUserId) {
      return SuscripcionModel.findOne({ revenueCatAppUserId: appUserId });
    },

    actualizarPorPadre(padreId, cambios) {
      return SuscripcionModel.findOneAndUpdate(
        { padreId },
        { $set: { ...cambios, actualizadoEn: new Date() } },
        { new: true, upsert: true, setDefaultsOnInsert: true },
      );
    },

    eliminarPorPadre(padreId) {
      return SuscripcionModel.deleteOne({ padreId });
    },
  };
}
