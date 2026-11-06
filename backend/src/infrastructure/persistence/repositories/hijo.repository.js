import { HijoModel } from '../mongoose/models/hijo.model.js';

export function normalizarNombreHijo(nombre) {
  return nombre
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

export function crearHijoRepository() {
  return {
    listarPorPadre(padreId) {
      return HijoModel.find({ padreId }).sort({ creadoEn: 1 });
    },

    buscarPorIdYPadre(hijoId, padreId) {
      return HijoModel.findOne({ _id: hijoId, padreId });
    },

    buscarPorNombre(padreId, nombre) {
      return HijoModel.findOne({
        padreId,
        nombreNormalizado: normalizarNombreHijo(nombre),
      });
    },

    crear(datos) {
      return HijoModel.create({
        ...datos,
        nombreNormalizado: normalizarNombreHijo(datos.nombre),
      });
    },

    eliminarPorIdYPadre(hijoId, padreId) {
      return HijoModel.findOneAndDelete({ _id: hijoId, padreId });
    },

    eliminarPorPadre(padreId) {
      return HijoModel.deleteMany({ padreId });
    },

    contarPorPadre(padreId) {
      return HijoModel.countDocuments({ padreId });
    },
  };
}
