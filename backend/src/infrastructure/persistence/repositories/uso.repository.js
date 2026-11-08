import { UsoMensualModel } from '../mongoose/models/uso_mensual.model.js';

export function crearUsoRepository() {
  return {
    /**
     * Incrementa el contador mensual de escaneos.
     *
     * Los escaneos son ilimitados para todos los planes; el contador se
     * conserva únicamente como estadística de uso.
     */
    async reservar({ padreId, periodo }) {
      const documento = await UsoMensualModel.findOneAndUpdate(
        { padreId, periodo },
        { $inc: { contador: 1 } },
        { new: true, upsert: true, setDefaultsOnInsert: true },
      );
      return { permitido: true, contador: documento?.contador ?? 1 };
    },

    async liberar({ padreId, periodo }) {
      await UsoMensualModel.updateOne(
        { padreId, periodo, contador: { $gt: 0 } },
        { $inc: { contador: -1 } },
      );
    },

    obtener({ padreId, periodo }) {
      return UsoMensualModel.findOne({ padreId, periodo });
    },
  };
}
