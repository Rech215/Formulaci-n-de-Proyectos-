/**
 * Padre — Modelo de datos del usuario (padre de familia).
 *
 * Aplica encapsulamiento total: todas las propiedades son privadas
 * y se acceden mediante getters/setters con validación.
 *
 * Responsabilidades:
 *   • Almacenar datos de perfil del padre
 *   • Gestionar la lista de hijos asociados
 *   • Proporcionar serialización limpia (toJSON)
 */

import { IPadre, IHijo, PadreDTO } from '../interfaces/IPadre';
import { TipoPlan } from '../interfaces/ISuscripcion';

export class Padre implements IPadre {
  // ── Propiedades privadas ──────────────────────────────────────────
  private _id: string;
  private _nombre: string;
  private _correo: string;
  private _hijos: IHijo[];
  private _planActual: TipoPlan;
  private _fechaRegistro: Date;

  // ── Constructor ───────────────────────────────────────────────────
  constructor(
    id: string,
    nombre: string,
    correo: string,
    hijos: IHijo[] = [],
    planActual: TipoPlan = TipoPlan.GRATUITO,
  ) {
    this.validarCorreo(correo);
    this.validarNombre(nombre);

    this._id = id;
    this._nombre = nombre.trim();
    this._correo = correo.trim().toLowerCase();
    this._hijos = [...hijos];                     // Copia defensiva
    this._planActual = planActual;
    this._fechaRegistro = new Date();
  }

  // ── Getters ───────────────────────────────────────────────────────
  get id(): string {
    return this._id;
  }

  get nombre(): string {
    return this._nombre;
  }

  get correo(): string {
    return this._correo;
  }

  get hijos(): IHijo[] {
    return [...this._hijos];                      // Copia defensiva
  }

  get planActual(): TipoPlan {
    return this._planActual;
  }

  get fechaRegistro(): Date {
    return new Date(this._fechaRegistro.getTime());
  }

  // ── Setters con validación ────────────────────────────────────────
  set nombre(valor: string) {
    this.validarNombre(valor);
    this._nombre = valor.trim();
  }

  set correo(valor: string) {
    this.validarCorreo(valor);
    this._correo = valor.trim().toLowerCase();
  }

  // ── Métodos públicos de negocio ───────────────────────────────────

  /**
   * Agrega un hijo a la lista del padre.
   * @throws Error si ya existe un hijo con el mismo nombre.
   */
  agregarHijo(hijo: IHijo): void {
    if (hijo.edad < 3 || hijo.edad > 18) {
      throw new Error(`Edad inválida: ${hijo.edad}. Debe estar entre 3 y 18 años.`);
    }
    const existente = this._hijos.find(
      (h) => h.nombre.toLowerCase() === hijo.nombre.toLowerCase(),
    );
    if (existente) {
      throw new Error(`Ya existe un hijo registrado con el nombre "${hijo.nombre}".`);
    }
    this._hijos.push({ ...hijo });                // Copia defensiva
  }

  /**
   * Elimina un hijo por nombre (comparación case-insensitive).
   * @returns true si se eliminó, false si no se encontró.
   */
  eliminarHijo(nombreHijo: string): boolean {
    const indice = this._hijos.findIndex(
      (h) => h.nombre.toLowerCase() === nombreHijo.toLowerCase(),
    );
    if (indice === -1) return false;
    this._hijos.splice(indice, 1);
    return true;
  }

  /**
   * Busca un hijo por nombre (case-insensitive).
   */
  obtenerHijoPorNombre(nombre: string): IHijo | undefined {
    const encontrado = this._hijos.find(
      (h) => h.nombre.toLowerCase() === nombre.toLowerCase(),
    );
    return encontrado ? { ...encontrado } : undefined;
  }

  /**
   * Actualiza el plan activo del padre (se invoca desde Suscripcion).
   */
  actualizarPlan(nuevoPlan: TipoPlan): void {
    this._planActual = nuevoPlan;
  }

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): PadreDTO {
    return {
      id: this._id,
      nombre: this._nombre,
      correo: this._correo,
      hijos: [...this._hijos],
      planActual: this._planActual,
      fechaRegistro: this._fechaRegistro.toISOString(),
    };
  }

  // ── Método estático — Factory desde DTO ───────────────────────────
  static fromDTO(dto: PadreDTO): Padre {
    const padre = new Padre(dto.id, dto.nombre, dto.correo, dto.hijos, dto.planActual);
    padre._fechaRegistro = new Date(dto.fechaRegistro);
    return padre;
  }

  // ── Validaciones privadas ─────────────────────────────────────────
  private validarCorreo(correo: string): void {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!regex.test(correo.trim())) {
      throw new Error(`Correo electrónico inválido: "${correo}".`);
    }
  }

  private validarNombre(nombre: string): void {
    if (!nombre || nombre.trim().length < 2) {
      throw new Error('El nombre debe tener al menos 2 caracteres.');
    }
  }
}

