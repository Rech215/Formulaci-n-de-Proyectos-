/**
 * ITarea — Contrato para el modelo de una tarea escaneada (imagen de tarea).
 *
 * Representa el ciclo completo: el padre sube una foto → la IA analiza
 * el tema y método SEP → genera preguntas guía para el padre.
 */

export interface ITarea {
  // ── Identificación ────────────────────────────────────────────────
  readonly id: string;
  readonly padreId: string;

  // ── Imagen escaneada ──────────────────────────────────────────────
  readonly imagenUrl: string;

  // ── Resultado del análisis IA ─────────────────────────────────────
  readonly estado: EstadoTarea;
  materia: string;
  temaDetectado: string;
  metodoSEP: string;
  preguntasGuia: string[];

  // ── Metadata ──────────────────────────────────────────────────────
  readonly fechaCreacion: Date;
  readonly nombreHijo: string;

  // ── Métodos de negocio ────────────────────────────────────────────
  iniciarAnalisis(): void;
  completarAnalisis(resultado: ResultadoAnalisis): void;
  marcarError(mensaje: string): void;

  // ── Serialización ─────────────────────────────────────────────────
  toJSON(): TareaDTO;
}

/**
 * Estados posibles de una tarea dentro de su ciclo de vida.
 */
export enum EstadoTarea {
  PENDIENTE   = 'PENDIENTE',     // Imagen subida, esperando análisis
  ANALIZANDO  = 'ANALIZANDO',   // IA procesando la imagen
  COMPLETADA  = 'COMPLETADA',   // Análisis terminado con éxito
  ERROR       = 'ERROR',         // Ocurrió un error en el análisis
}

/**
 * ResultadoAnalisis — Datos que devuelve la IA tras procesar la imagen.
 */
export interface ResultadoAnalisis {
  materia: string;             // Ej: "Matemáticas", "Español"
  temaDetectado: string;       // Ej: "Fracciones equivalentes"
  metodoSEP: string;           // Explicación del método actual de la SEP
  preguntasGuia: string[];     // 2-3 preguntas para que el padre guíe al hijo
}

/**
 * TareaDTO — Objeto plano para transferencia de datos.
 */
export interface TareaDTO {
  id: string;
  padreId: string;
  imagenUrl: string;
  estado: EstadoTarea;
  materia: string;
  temaDetectado: string;
  metodoSEP: string;
  preguntasGuia: string[];
  nombreHijo: string;
  fechaCreacion: string;   // ISO 8601
  mensajeError?: string;
}

