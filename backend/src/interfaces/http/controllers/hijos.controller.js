import { AppError, NoEncontradoError } from '../../../domain/errors.js';
import {
  normalizarNombreHijo,
} from '../../../infrastructure/persistence/repositories/hijo.repository.js';
import { serializarPadre } from '../../../application/serializers.js';

export function crearHijosController({ padreRepository, hijoRepository }) {
  async function responderPadre(res, padreId, status = 200) {
    const padre = await padreRepository.buscarPorId(padreId);
    const hijos = await hijoRepository.listarPorPadre(padreId);
    return res.status(status).json({ padre: serializarPadre(padre, hijos) });
  }

  return {
    async listar(req, res) {
      const hijos = await hijoRepository.listarPorPadre(req.padre._id);
      return res.json({
        hijos: hijos.map((hijo) => ({
          id: hijo._id.toString(),
          nombre: hijo.nombre,
          edad: hijo.edad,
          gradoEscolar: hijo.gradoEscolar,
        })),
      });
    },

    async crear(req, res) {
      const { nombre, edad, gradoEscolar } = req.body;
      const existente = await hijoRepository.buscarPorNombre(
        req.padre._id,
        nombre,
      );

      if (existente) {
        throw new AppError(
          `Ya registraste un hijo llamado "${nombre}".`,
          { status: 409, code: 'HIJO_DUPLICADO' },
        );
      }

      await hijoRepository.crear({
        padreId: req.padre._id,
        nombre,
        edad,
        gradoEscolar,
      });

      return responderPadre(res, req.padre._id, 201);
    },

    async eliminar(req, res) {
      const { hijoId } = req.params;

      if (hijoId) {
        const eliminado = await hijoRepository.eliminarPorIdYPadre(
          hijoId,
          req.padre._id,
        );
        if (!eliminado) {
          throw new NoEncontradoError('No encontramos ese hijo en tu cuenta.');
        }
      } else {
        const nombre = req.query.nombre;
        const hijo = await hijoRepository.buscarPorNombre(
          req.padre._id,
          nombre,
        );
        if (!hijo) {
          throw new NoEncontradoError('No encontramos ese hijo en tu cuenta.');
        }
        await hijoRepository.eliminarPorIdYPadre(hijo._id, req.padre._id);
      }

      return responderPadre(res, req.padre._id);
    },

    normalizarNombreHijo,
  };
}
