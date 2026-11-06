import { UsoMensualModel } from '../mongoose/models/uso_mensual.model.js';

function esErrorDuplicado(error) {
  return error?.code === 11000;
}

export function crearUsoRepository() {
  return {
    /**
     * Reserva atómicamente una consulta.
     *
     * - Plan premium (`limite === null`): solo incrementa estadísticas.
     * - Plan gratuito: el `findOneAndUpdate` condicionado a `contador < limite`
     *   evita que dos peticiones simultáneas rebasen las 5 tareas.
     */
    async reservar({ padreId, periodo, limite }) {
      if (limite === null) {
        const documento = await UsoMensualModel.findOneAndUpdate(
          { padreId, periodo },
          { $inc: { contador: 1 } },
          { new: true, upsert: true, setDefaultsOnInsert: true },
        );
        return { permitido: true, contador: documento?.contador ?? 1 };
      }

      for (let intento = 0; intento < 2; intento += 1) {
        try {
          const documento = await UsoMensualModel.findOneAndUpdate(
            { padreId, periodo, contador: { $lt: limite } },
            { $inc: { contador: 1 } },
            { new: true },
          );

          if (documento) {
            return { permitido: true, contador: documento.contador };
          }

          await UsoMensualModel.updateOne(
            { padreId, periodo },
            { $setOnInsert: { contador: 0 } },
            { upsert: true },
          );

          const actual = await UsoMensualModel.findOne({ padreId, periodo });
          return { permitido: false, contador: actual?.contador ?? limite };
        } catch (error) {
          if (esErrorDuplicado(error) && intento === 0) {
            continue;
          }
          throw error;
        }
      }

      return { permitido: false, contador: limite };
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
