/**
 * Express 4 no captura promesas rechazadas automáticamente.
 * Este envoltorio delega cualquier error al middleware de errores.
 */
export function asyncHandler(handler) {
  return function envoltorio(req, res, next) {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}
