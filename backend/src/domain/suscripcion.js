export const PLAN_GRATUITO = 'GRATUITO';
export const PLAN_PREMIUM = 'PREMIUM';

export const LIMITE_CONSULTAS_GRATUITO = 5;

export const ESTADO_SUSCRIPCION = Object.freeze({
  ACTIVA: 'ACTIVA',
  CANCELADA: 'CANCELADA',
  EXPIRADA: 'EXPIRADA',
});

export function esPlanPremium(plan) {
  return plan === PLAN_PREMIUM;
}

/**
 * Límite mensual del plan. `null` significa ilimitado.
 */
export function limiteDelPlan(plan) {
  return esPlanPremium(plan) ? null : LIMITE_CONSULTAS_GRATUITO;
}

/**
 * Periodo mensual en formato YYYY-MM (UTC) usado para el contador de uso.
 */
export function periodoActual(fecha = new Date()) {
  const anio = fecha.getUTCFullYear();
  const mes = String(fecha.getUTCMonth() + 1).padStart(2, '0');
  return `${anio}-${mes}`;
}

export function estaSuscripcionVigente(suscripcion, fecha = new Date()) {
  if (!suscripcion || suscripcion.estado !== ESTADO_SUSCRIPCION.ACTIVA) {
    return false;
  }
  if (!suscripcion.fechaRenovacion) return true;
  return new Date(suscripcion.fechaRenovacion) > fecha;
}
