/**
 * IPadre — Contrato para el modelo de datos del usuario (Padre de familia).
 *
 * Define la estructura que debe cumplir cualquier implementación del Padre,
 * separando la firma pública de los detalles internos de la clase.
 */

import { TipoPlan } from './ISuscripcion';

export interface IPadre {
  // ── Identificación ────────────────────────────────────────────────
  readonly id: string;
  nombre: string;
  correo: string;

  // ── Datos de los hijos ────────────────────────────────────────────
  readonly hijos: IHijo[];

  // ── Suscripción activa ────────────────────────────────────────────
  readonly planActual: TipoPlan;

  // ── Métodos de negocio ────────────────────────────────────────────
  agregarHijo(hijo: IHijo): void;
  eliminarHijo(nombreHijo: string): boolean;
  obtenerHijoPorNombre(nombre: string): IHijo | undefined;

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): PadreDTO;
}

/**
 * IHijo — Información básica de un hijo asociado al padre.
 */
export interface IHijo {
  nombre: string;
  edad: number;
  gradoEscolar: string;   // Ej: "3ro Primaria", "1ro Secundaria"
}

/**
 * PadreDTO — Objeto plano para transferencia de datos (sin métodos).
 * Se utiliza para serialización, API responses y persistencia.
 */
export interface PadreDTO {
  id: string;
  nombre: string;
  correo: string;
  hijos: IHijo[];
  planActual: TipoPlan;
  fechaRegistro: string;   // ISO 8601
}

