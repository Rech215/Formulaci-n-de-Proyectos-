/**
 * Suscripcion — Modelo de datos para la suscripción del padre.
 *
 * Planes de EduGuía:
 *   • GRATUITO → 5 consultas/mes, sin costo
 *   • PREMIUM  → consultas ilimitadas, $99 MXN/mes
 *
 * Controla el límite de consultas y las transiciones de plan.
 */

import {
  ISuscripcion,
  TipoPlan,
  EstadoSuscripcion,
  SuscripcionDTO,
} from '../interfaces/ISuscripcion';

export class Suscripcion implements ISuscripcion {
  // ── Constantes ────────────────────────────────────────────────────
  private static readonly LIMITE_GRATUITO = 5;
  private static readonly LIMITE_PREMIUM = Infinity;
  private static readonly PRECIO_PREMIUM_MXN = 99;

  // ── Propiedades privadas ──────────────────────────────────────────
  private _id: string;
  private _padreId: string;
  private _tipoPlan: TipoPlan;
  private _estado: EstadoSuscripcion;
  private _consultasUsadas: number;
  private _limiteConsultas: number;
  private _fechaInicio: Date;
  private _fechaRenovacion: Date | null;

  // ── Constructor ───────────────────────────────────────────────────
  constructor(
    id: string,
    padreId: string,
    tipoPlan: TipoPlan = TipoPlan.GRATUITO,
  ) {
    this._id = id;
    this._padreId = padreId;
    this._tipoPlan = tipoPlan;
    this._estado = EstadoSuscripcion.ACTIVA;
    this._consultasUsadas = 0;
    this._limiteConsultas = this.calcularLimite(tipoPlan);
    this._fechaInicio = new Date();
    this._fechaRenovacion = this.calcularRenovacion(tipoPlan);
  }

  // ── Getters ───────────────────────────────────────────────────────
  get id(): string {
    return this._id;
  }

  get padreId(): string {
    return this._padreId;
  }

  get tipoPlan(): TipoPlan {
    return this._tipoPlan;
  }

  get estado(): EstadoSuscripcion {
    return this._estado;
  }

  get consultasUsadas(): number {
    return this._consultasUsadas;
  }

  get limiteConsultas(): number {
    return this._limiteConsultas;
  }

  get consultasRestantes(): number {
    if (this._limiteConsultas === Infinity) return Infinity;
    return Math.max(0, this._limiteConsultas - this._consultasUsadas);
  }

  get fechaInicio(): Date {
    return new Date(this._fechaInicio.getTime());
  }

  get fechaRenovacion(): Date | null {
    return this._fechaRenovacion
      ? new Date(this._fechaRenovacion.getTime())
      : null;
  }

  get esPremium(): boolean {
    return this._tipoPlan === TipoPlan.PREMIUM;
  }

  get precioMensual(): number {
    return this._tipoPlan === TipoPlan.PREMIUM
      ? Suscripcion.PRECIO_PREMIUM_MXN
      : 0;
  }

  // ── Métodos de negocio ────────────────────────────────────────────

  /**
   * Verifica si el padre puede realizar una nueva consulta.
   * @returns true si la suscripción está activa y no ha alcanzado el límite.
   */
  puedeConsultar(): boolean {
    if (this._estado !== EstadoSuscripcion.ACTIVA) {
      return false;
    }
    return this._consultasUsadas < this._limiteConsultas;
  }

  /**
   * Registra el uso de una consulta (escaneo de tarea).
   * @throws Error si no puede consultar (límite alcanzado o suscripción inactiva).
   */
  registrarConsulta(): void {
    if (!this.puedeConsultar()) {
      if (this._estado !== EstadoSuscripcion.ACTIVA) {
        throw new Error('La suscripción no está activa.');
      }
      throw new Error(
        `Has alcanzado el límite de ${this._limiteConsultas} consultas mensuales. ` +
        'Actualiza a Premium para consultas ilimitadas.',
      );
    }
    this._consultasUsadas++;
  }

  /**
   * Cambia el plan del padre (upgrade o downgrade).
   * @throws Error si se intenta cambiar al mismo plan.
   */
  actualizarPlan(nuevoPlan: TipoPlan): void {
    if (nuevoPlan === this._tipoPlan) {
      throw new Error(`Ya cuentas con el plan ${nuevoPlan}.`);
    }

    this._tipoPlan = nuevoPlan;
    this._limiteConsultas = this.calcularLimite(nuevoPlan);
    this._estado = EstadoSuscripcion.ACTIVA;
    this._fechaRenovacion = this.calcularRenovacion(nuevoPlan);

    // Al hacer upgrade, no se resetean las consultas usadas del ciclo actual
    // Al hacer downgrade, se ajusta si ya excedió el nuevo límite
    if (nuevoPlan === TipoPlan.GRATUITO && this._consultasUsadas > this._limiteConsultas) {
      // El padre mantiene las consultas ya usadas pero no podrá hacer más
      // hasta que se reinicie el ciclo
    }
  }

  /**
   * Cancela la suscripción. El acceso se mantiene hasta la fecha de renovación.
   * @throws Error si ya está cancelada.
   */
  cancelar(): void {
    if (this._estado === EstadoSuscripcion.CANCELADA) {
      throw new Error('La suscripción ya está cancelada.');
    }
    this._estado = EstadoSuscripcion.CANCELADA;
  }

  /**
   * Reinicia el ciclo mensual: resetea el contador de consultas.
   * Se invoca al inicio de cada nuevo periodo de facturación.
   */
  reiniciarCiclo(): void {
    this._consultasUsadas = 0;
    if (this._estado === EstadoSuscripcion.ACTIVA) {
      this._fechaRenovacion = this.calcularRenovacion(this._tipoPlan);
    }
  }

  /**
   * Reactiva una suscripción cancelada o expirada.
   */
  reactivar(): void {
    if (this._estado === EstadoSuscripcion.ACTIVA) {
      throw new Error('La suscripción ya está activa.');
    }
    this._estado = EstadoSuscripcion.ACTIVA;
    this._fechaRenovacion = this.calcularRenovacion(this._tipoPlan);
  }

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): SuscripcionDTO {
    return {
      id: this._id,
      padreId: this._padreId,
      tipoPlan: this._tipoPlan,
      estado: this._estado,
      consultasUsadas: this._consultasUsadas,
      limiteConsultas: this._limiteConsultas === Infinity
        ? -1    // JSON no soporta Infinity; -1 indica ilimitado
        : this._limiteConsultas,
      fechaInicio: this._fechaInicio.toISOString(),
      fechaRenovacion: this._fechaRenovacion?.toISOString() ?? null,
    };
  }

  // ── Factory estático ──────────────────────────────────────────────
  static fromDTO(dto: SuscripcionDTO): Suscripcion {
    const sub = new Suscripcion(dto.id, dto.padreId, dto.tipoPlan);
    sub._estado = dto.estado;
    sub._consultasUsadas = dto.consultasUsadas;
    sub._limiteConsultas = dto.limiteConsultas === -1
      ? Infinity
      : dto.limiteConsultas;
    sub._fechaInicio = new Date(dto.fechaInicio);
    sub._fechaRenovacion = dto.fechaRenovacion
      ? new Date(dto.fechaRenovacion)
      : null;
    return sub;
  }

  // ── Métodos privados ──────────────────────────────────────────────
  private calcularLimite(plan: TipoPlan): number {
    return plan === TipoPlan.PREMIUM
      ? Suscripcion.LIMITE_PREMIUM
      : Suscripcion.LIMITE_GRATUITO;
  }

  private calcularRenovacion(plan: TipoPlan): Date | null {
    if (plan === TipoPlan.GRATUITO) return null;
    const renovacion = new Date();
    renovacion.setMonth(renovacion.getMonth() + 1);
    return renovacion;
  }
}

