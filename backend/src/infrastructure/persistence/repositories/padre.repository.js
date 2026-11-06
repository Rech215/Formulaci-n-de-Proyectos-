import { PadreModel } from '../mongoose/models/padre.model.js';

export function crearPadreRepository() {
  return {
    crear(datos) {
      return PadreModel.create(datos);
    },

    buscarPorId(padreId) {
      return PadreModel.findById(padreId);
    },

    buscarPorCorreo(correo) {
      return PadreModel.findOne({ correo: correo.trim().toLowerCase() });
    },

    buscarPorCorreoConPassword(correo) {
      return PadreModel.findOne({
        correo: correo.trim().toLowerCase(),
      }).select('+passwordHash');
    },

    buscarPorRevenueCatAppUserId(appUserId) {
      return PadreModel.findOne({ revenueCatAppUserId: appUserId });
    },

    async actualizarPlan(padreId, plan) {
      return PadreModel.findByIdAndUpdate(
        padreId,
        { $set: { plan } },
        { new: true },
      );
    },

    async vincularRevenueCat(padreId, appUserId) {
      return PadreModel.findByIdAndUpdate(
        padreId,
        { $set: { revenueCatAppUserId: appUserId } },
        { new: true },
      );
    },

    eliminarPorId(padreId) {
      return PadreModel.findByIdAndDelete(padreId);
    },
  };
}
