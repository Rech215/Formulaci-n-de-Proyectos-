import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import {
  AppError,
  NoAutorizadoError,
} from '../../domain/errors.js';
import { normalizarNombreHijo } from '../../infrastructure/persistence/repositories/hijo.repository.js';

const COSTO_BCRYPT = 12;

export function crearAuthService({
  padreRepository,
  hijoRepository,
  suscripcionRepository,
  jwtSecret,
  jwtExpiresIn,
}) {
  function firmarToken(padre) {
    return jwt.sign(
      { sub: padre._id.toString() },
      jwtSecret,
      { expiresIn: jwtExpiresIn },
    );
  }

  return {
    async registrar({ nombre, correo, password, hijos = [] }) {
      const existente = await padreRepository.buscarPorCorreo(correo);
      if (existente) {
        throw new AppError('Ya existe una cuenta con ese correo.', {
          status: 409,
          code: 'CORREO_DUPLICADO',
        });
      }

      const nombres = new Set();
      for (const hijo of hijos) {
        const normalizado = normalizarNombreHijo(hijo.nombre);
        if (nombres.has(normalizado)) {
          throw new AppError(
            `El hijo "${hijo.nombre}" está repetido en la solicitud.`,
            { code: 'HIJO_DUPLICADO' },
          );
        }
        nombres.add(normalizado);
      }

      const passwordHash = await bcrypt.hash(password, COSTO_BCRYPT);
      const padre = await padreRepository.crear({
        nombre,
        correo,
        passwordHash,
        plan: 'GRATUITO',
        revenueCatAppUserId: null,
      });

      try {
        await suscripcionRepository.obtenerOCrear(padre._id);

        for (const hijo of hijos) {
          await hijoRepository.crear({
            padreId: padre._id,
            nombre: hijo.nombre,
            edad: hijo.edad,
            gradoEscolar: hijo.gradoEscolar,
          });
        }
      } catch (error) {
        await Promise.allSettled([
          hijoRepository.eliminarPorPadre?.(padre._id),
          suscripcionRepository.eliminarPorPadre?.(padre._id),
          padreRepository.eliminarPorId?.(padre._id),
        ]);
        throw error;
      }

      const hijosCreados = await hijoRepository.listarPorPadre(padre._id);

      return {
        token: firmarToken(padre),
        padre,
        hijos: hijosCreados,
      };
    },

    async iniciarSesion({ correo, password }) {
      const padre = await padreRepository.buscarPorCorreoConPassword(correo);
      if (!padre) {
        throw new NoAutorizadoError('Correo o contraseña incorrectos.');
      }

      const coincide = await bcrypt.compare(password, padre.passwordHash);
      if (!coincide) {
        throw new NoAutorizadoError('Correo o contraseña incorrectos.');
      }

      const hijos = await hijoRepository.listarPorPadre(padre._id);

      return {
        token: firmarToken(padre),
        padre,
        hijos,
      };
    },

    verificarToken(token) {
      try {
        return jwt.verify(token, jwtSecret);
      } catch {
        throw new NoAutorizadoError('Token inválido o expirado.');
      }
    },
  };
}
