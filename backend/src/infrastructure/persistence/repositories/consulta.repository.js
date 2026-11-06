import { ConsultaModel } from '../mongoose/models/consulta.model.js';

export function crearConsultaRepository() {
  return {
    crear(datos) {
      return ConsultaModel.create(datos);
    },

    listarPorPadre(padreId, { limite = 50, salto = 0 } = {}) {
      return ConsultaModel.find({ padreId })
        .sort({ creadoEn: -1 })
        .skip(salto)
        .limit(Math.min(limite, 100));
    },

    buscarPorIdYPadre(consultaId, padreId) {
      return ConsultaModel.findOne({ _id: consultaId, padreId });
    },

    contarPorPadre(padreId) {
      return ConsultaModel.countDocuments({ padreId });
    },

    contarCompletadas(padreId) {
      return ConsultaModel.countDocuments({
        padreId,
        estado: 'COMPLETADA',
      });
    },
  };
}
