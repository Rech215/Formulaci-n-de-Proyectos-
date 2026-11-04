/**
 * Tarea — Modelo de datos para una imagen de tarea escaneada.
 *
 * Ciclo de vida:
 *   PENDIENTE → ANALIZANDO → COMPLETADA
 *                          → ERROR
 *
 * Encapsula todo el estado del análisis IA y las preguntas guía
 * generadas para que el padre acompañe al hijo.
 */

import {
  ITarea,
  EstadoTarea,
  ResultadoAnalisis,
  TareaDTO,
} from '../interfaces/ITarea';

export class Tarea implements ITarea {
  // ── Propiedades privadas ──────────────────────────────────────────
  private _id: string;
  private _padreId: string;
  private _imagenUrl: string;
  private _estado: EstadoTarea;
  private _materia: string;
  private _temaDetectado: string;
  private _metodoSEP: string;
  private _preguntasGuia: string[];
  private _fechaCreacion: Date;
  private _nombreHijo: string;
  private _mensajeError: string | null;

  // ── Constructor ───────────────────────────────────────────────────
  constructor(
    id: string,
    padreId: string,
    imagenUrl: string,
    nombreHijo: string,
  ) {
    this.validarUrl(imagenUrl);

    this._id = id;
    this._padreId = padreId;
    this._imagenUrl = imagenUrl;
    this._nombreHijo = nombreHijo;
    this._estado = EstadoTarea.PENDIENTE;
    this._materia = '';
    this._temaDetectado = '';
    this._metodoSEP = '';
    this._preguntasGuia = [];
    this._fechaCreacion = new Date();
    this._mensajeError = null;
  }

  // ── Getters ───────────────────────────────────────────────────────
  get id(): string {
    return this._id;
  }

  get padreId(): string {
    return this._padreId;
  }

  get imagenUrl(): string {
    return this._imagenUrl;
  }

  get estado(): EstadoTarea {
    return this._estado;
  }

  get materia(): string {
    return this._materia;
  }

  get temaDetectado(): string {
    return this._temaDetectado;
  }

  get metodoSEP(): string {
    return this._metodoSEP;
  }

  get preguntasGuia(): string[] {
    return [...this._preguntasGuia];             // Copia defensiva
  }

  get fechaCreacion(): Date {
    return new Date(this._fechaCreacion.getTime());
  }

  get nombreHijo(): string {
    return this._nombreHijo;
  }

  get mensajeError(): string | null {
    return this._mensajeError;
  }

  // ── Setters (solo campos editables post-creación) ─────────────────
  set materia(valor: string) {
    this._materia = valor;
  }

  set temaDetectado(valor: string) {
    this._temaDetectado = valor;
  }

  set metodoSEP(valor: string) {
    this._metodoSEP = valor;
  }

  set preguntasGuia(valor: string[]) {
    this._preguntasGuia = [...valor];
  }

  // ── Métodos de negocio (máquina de estados) ───────────────────────

  /**
   * Transiciona la tarea de PENDIENTE → ANALIZANDO.
   * @throws Error si la tarea no está en estado PENDIENTE.
   */
  iniciarAnalisis(): void {
    if (this._estado !== EstadoTarea.PENDIENTE) {
      throw new Error(
        `No se puede iniciar análisis: la tarea está en estado "${this._estado}".`,
      );
    }
    this._estado = EstadoTarea.ANALIZANDO;
  }

  /**
   * Transiciona de ANALIZANDO → COMPLETADA y asigna los resultados.
   * @throws Error si la tarea no está en estado ANALIZANDO.
   */
  completarAnalisis(resultado: ResultadoAnalisis): void {
    if (this._estado !== EstadoTarea.ANALIZANDO) {
      throw new Error(
        `No se puede completar: la tarea está en estado "${this._estado}".`,
      );
    }
    this.validarResultado(resultado);

    this._materia = resultado.materia;
    this._temaDetectado = resultado.temaDetectado;
    this._metodoSEP = resultado.metodoSEP;
    this._preguntasGuia = [...resultado.preguntasGuia];
    this._estado = EstadoTarea.COMPLETADA;
    this._mensajeError = null;
  }

  /**
   * Transiciona a ERROR desde cualquier estado no-final.
   */
  marcarError(mensaje: string): void {
    if (this._estado === EstadoTarea.COMPLETADA) {
      throw new Error('No se puede marcar error en una tarea ya completada.');
    }
    this._estado = EstadoTarea.ERROR;
    this._mensajeError = mensaje;
  }

  /**
   * Indica si la tarea terminó (exitosa o con error).
   */
  esFinal(): boolean {
    return (
      this._estado === EstadoTarea.COMPLETADA ||
      this._estado === EstadoTarea.ERROR
    );
  }

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): TareaDTO {
    return {
      id: this._id,
      padreId: this._padreId,
      imagenUrl: this._imagenUrl,
      estado: this._estado,
      materia: this._materia,
      temaDetectado: this._temaDetectado,
      metodoSEP: this._metodoSEP,
      preguntasGuia: [...this._preguntasGuia],
      nombreHijo: this._nombreHijo,
      fechaCreacion: this._fechaCreacion.toISOString(),
      ...(this._mensajeError && { mensajeError: this._mensajeError }),
    };
  }

  // ── Factory estático ──────────────────────────────────────────────
  static fromDTO(dto: TareaDTO): Tarea {
    const tarea = new Tarea(dto.id, dto.padreId, dto.imagenUrl, dto.nombreHijo);
    tarea._estado = dto.estado;
    tarea._materia = dto.materia;
    tarea._temaDetectado = dto.temaDetectado;
    tarea._metodoSEP = dto.metodoSEP;
    tarea._preguntasGuia = [...dto.preguntasGuia];
    tarea._fechaCreacion = new Date(dto.fechaCreacion);
    tarea._mensajeError = dto.mensajeError ?? null;
    return tarea;
  }

  // ── Validaciones privadas ─────────────────────────────────────────
  private validarUrl(url: string): void {
    if (!url || url.trim().length === 0) {
      throw new Error('La URL de la imagen no puede estar vacía.');
    }
  }

  private validarResultado(resultado: ResultadoAnalisis): void {
    if (!resultado.materia || !resultado.temaDetectado) {
      throw new Error('El resultado del análisis debe incluir materia y tema detectado.');
    }
    if (!resultado.preguntasGuia || resultado.preguntasGuia.length === 0) {
      throw new Error('El resultado debe incluir al menos una pregunta guía.');
    }
  }
}

