/**
 * ISuscripcion — Contrato para el modelo de suscripción del padre.
 *
 * Maneja los dos planes de EduGuía:
 *   • Gratuito  → 5 consultas/mes
 *   • Premium   → consultas ilimitadas ($99 MXN/mes)
 */

export interface ISuscripcion {
  // ── Identificación ────────────────────────────────────────────────
  readonly id: string;
  readonly padreId: string;

  // ── Plan ──────────────────────────────────────────────────────────
  readonly tipoPlan: TipoPlan;
  readonly estado: EstadoSuscripcion;

  // ── Límites ───────────────────────────────────────────────────────
  readonly consultasUsadas: number;
  readonly limiteConsultas: number;   // 5 para gratuito, Infinity para premium

  // ── Fechas ────────────────────────────────────────────────────────
  readonly fechaInicio: Date;
  readonly fechaRenovacion: Date | null;

  // ── Métodos de negocio ────────────────────────────────────────────
  puedeConsultar(): boolean;
  registrarConsulta(): void;
  actualizarPlan(nuevoPlan: TipoPlan): void;
  cancelar(): void;
  reiniciarCiclo(): void;

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): SuscripcionDTO;
}

/**
 * Tipos de plan disponibles.
 */
export enum TipoPlan {
  GRATUITO = 'GRATUITO',
  PREMIUM  = 'PREMIUM',
}

/**
 * Estados posibles de una suscripción.
 */
export enum EstadoSuscripcion {
  ACTIVA    = 'ACTIVA',
  CANCELADA = 'CANCELADA',
  EXPIRADA  = 'EXPIRADA',
}

/**
 * SuscripcionDTO — Objeto plano para transferencia de datos.
 */
export interface SuscripcionDTO {
  id: string;
  padreId: string;
  tipoPlan: TipoPlan;
  estado: EstadoSuscripcion;
  consultasUsadas: number;
  limiteConsultas: number;
  fechaInicio: string;             // ISO 8601
  fechaRenovacion: string | null;  // ISO 8601
}

