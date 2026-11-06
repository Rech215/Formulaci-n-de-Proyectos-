import { NoAutorizadoError } from '../../../domain/errors.js';
import { asyncHandler } from './asyncHandler.js';

/**
 * Middleware de autenticación JWT.
 *
 * Solo se acepta el token en la cabecera `Authorization: Bearer <token>`.
 * El padre autenticado se adjunta a `req.padre` para que los controladores
 * nunca confíen en un `padreId` enviado por el cliente.
 */
export function crearAutenticacion({ authService, padreRepository }) {
  return asyncHandler(async (req, _res, next) => {
    const cabecera = req.headers.authorization ?? '';
    const [esquema, token] = cabecera.split(' ');

    if (esquema !== 'Bearer' || !token) {
      throw new NoAutorizadoError('Falta el token de acceso.');
    }

    const payload = authService.verificarToken(token.trim());
    const padre = await padreRepository.buscarPorId(payload.sub);

    if (!padre) {
      throw new NoAutorizadoError('La sesión ya no es válida.');
    }

    req.padre = padre;
    next();
  });
}
