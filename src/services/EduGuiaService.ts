/**
 * EduGuiaService — Capa de lógica de negocio.
 *
 * Orquesta la interacción entre Padre, Tarea y Suscripción.
 * Actúa como fachada (Facade Pattern) para que la interfaz de usuario
 * nunca acceda directamente a los modelos ni a sus reglas internas.
 *
 * La UI solo interactúa con este servicio; los modelos permanecen
 * completamente encapsulados detrás de esta capa.
 */

import { Padre } from '../models/Padre';
import { Tarea } from '../models/Tarea';
import { Suscripcion } from '../models/Suscripcion';
import {
  IHijo,
  TipoPlan,
  EstadoTarea,
  ResultadoAnalisis,
  PadreDTO,
  TareaDTO,
  SuscripcionDTO,
} from '../interfaces/index';

export class EduGuiaService {
  // ── Almacenamiento en memoria (reemplazable por repositorio) ──────
  private padres: Map<string, Padre> = new Map();
  private tareas: Map<string, Tarea> = new Map();
  private suscripciones: Map<string, Suscripcion> = new Map();  // padreId → Suscripcion
  private contadorId: number = 0;

  // ── Generador de IDs ─────────────────────────────────────────────
  private generarId(prefijo: string): string {
    this.contadorId++;
    return `${prefijo}_${Date.now()}_${this.contadorId}`;
  }

  // ═══════════════════════════════════════════════════════════════════
  //   GESTIÓN DE PADRES
  // ═══════════════════════════════════════════════════════════════════

  /**
   * Registra un nuevo padre en el sistema.
   * Automáticamente crea una suscripción gratuita.
   */
  registrarPadre(nombre: string, correo: string, hijos: IHijo[] = []): PadreDTO {
    // Verificar que el correo no esté ya registrado
    for (const padre of this.padres.values()) {
      if (padre.correo === correo.trim().toLowerCase()) {
        throw new Error(`Ya existe una cuenta registrada con el correo "${correo}".`);
      }
    }

    const padreId = this.generarId('padre');
    const padre = new Padre(padreId, nombre, correo, hijos);
    this.padres.set(padreId, padre);

    // Crear suscripción gratuita automáticamente
    const subId = this.generarId('sub');
    const suscripcion = new Suscripcion(subId, padreId, TipoPlan.GRATUITO);
    this.suscripciones.set(padreId, suscripcion);

    return padre.toJSON();
  }

  /**
   * Obtiene los datos de un padre por su ID.
   */
  obtenerPadre(padreId: string): PadreDTO {
    const padre = this.buscarPadre(padreId);
    return padre.toJSON();
  }

  /**
   * Agrega un hijo al perfil del padre.
   */
  agregarHijo(padreId: string, hijo: IHijo): PadreDTO {
    const padre = this.buscarPadre(padreId);
    padre.agregarHijo(hijo);
    return padre.toJSON();
  }

  /**
   * Elimina un hijo del perfil del padre.
   */
  eliminarHijo(padreId: string, nombreHijo: string): PadreDTO {
    const padre = this.buscarPadre(padreId);
    const eliminado = padre.eliminarHijo(nombreHijo);
    if (!eliminado) {
      throw new Error(`No se encontró un hijo con el nombre "${nombreHijo}".`);
    }
    return padre.toJSON();
  }

  // ═══════════════════════════════════════════════════════════════════
  //   GESTIÓN DE TAREAS (ESCANEO DE IMÁGENES)
  // ═══════════════════════════════════════════════════════════════════

  /**
   * Crea una nueva tarea a partir de una imagen escaneada.
   * Verifica que la suscripción permita otra consulta.
   */
  crearTarea(padreId: string, imagenUrl: string, nombreHijo: string): TareaDTO {
    this.buscarPadre(padreId);    // Verifica que el padre exista
    const suscripcion = this.buscarSuscripcion(padreId);

    // Validar que tenga consultas disponibles
    if (!suscripcion.puedeConsultar()) {
      throw new Error(
        'Has alcanzado el límite de consultas de tu plan. ' +
        'Actualiza a Premium para consultas ilimitadas.',
      );
    }

    // Registrar la consulta
    suscripcion.registrarConsulta();

    // Crear la tarea
    const tareaId = this.generarId('tarea');
    const tarea = new Tarea(tareaId, padreId, imagenUrl, nombreHijo);
    this.tareas.set(tareaId, tarea);

    return tarea.toJSON();
  }

  /**
   * Inicia el análisis IA de una tarea (transición de estado).
   */
  iniciarAnalisisTarea(tareaId: string): TareaDTO {
    const tarea = this.buscarTarea(tareaId);
    tarea.iniciarAnalisis();
    return tarea.toJSON();
  }

  /**
   * Completa el análisis con los resultados de la IA.
   */
  completarAnalisisTarea(tareaId: string, resultado: ResultadoAnalisis): TareaDTO {
    const tarea = this.buscarTarea(tareaId);
    tarea.completarAnalisis(resultado);
    return tarea.toJSON();
  }

  /**
   * Marca una tarea con error de análisis.
   */
  marcarErrorTarea(tareaId: string, mensaje: string): TareaDTO {
    const tarea = this.buscarTarea(tareaId);
    tarea.marcarError(mensaje);
    return tarea.toJSON();
  }

  /**
   * Obtiene todas las tareas de un padre.
   */
  obtenerTareasPorPadre(padreId: string): TareaDTO[] {
    this.buscarPadre(padreId);
    const resultado: TareaDTO[] = [];
    for (const tarea of this.tareas.values()) {
      if (tarea.padreId === padreId) {
        resultado.push(tarea.toJSON());
      }
    }
    return resultado.sort(
      (a, b) => new Date(b.fechaCreacion).getTime() - new Date(a.fechaCreacion).getTime(),
    );
  }

  /**
   * Obtiene una tarea específica.
   */
  obtenerTarea(tareaId: string): TareaDTO {
    return this.buscarTarea(tareaId).toJSON();
  }

  // ═══════════════════════════════════════════════════════════════════
  //   GESTIÓN DE SUSCRIPCIONES
  // ═══════════════════════════════════════════════════════════════════

  /**
   * Obtiene la suscripción activa del padre.
   */
  obtenerSuscripcion(padreId: string): SuscripcionDTO {
    const suscripcion = this.buscarSuscripcion(padreId);
    return suscripcion.toJSON();
  }

  /**
   * Actualiza el plan del padre (upgrade/downgrade).
   */
  actualizarPlan(padreId: string, nuevoPlan: TipoPlan): SuscripcionDTO {
    const padre = this.buscarPadre(padreId);
    const suscripcion = this.buscarSuscripcion(padreId);

    suscripcion.actualizarPlan(nuevoPlan);
    padre.actualizarPlan(nuevoPlan);

    return suscripcion.toJSON();
  }

  /**
   * Cancela la suscripción premium del padre.
   */
  cancelarSuscripcion(padreId: string): SuscripcionDTO {
    const padre = this.buscarPadre(padreId);
    const suscripcion = this.buscarSuscripcion(padreId);

    suscripcion.cancelar();
    padre.actualizarPlan(TipoPlan.GRATUITO);

    return suscripcion.toJSON();
  }

  /**
   * Verifica si el padre puede realizar una consulta.
   */
  puedeConsultar(padreId: string): boolean {
    const suscripcion = this.buscarSuscripcion(padreId);
    return suscripcion.puedeConsultar();
  }

  /**
   * Obtiene un resumen del uso del padre (para la UI).
   */
  obtenerResumenUso(padreId: string): ResumenUso {
    const padre = this.buscarPadre(padreId);
    const suscripcion = this.buscarSuscripcion(padreId);
    const tareas = this.obtenerTareasPorPadre(padreId);

    return {
      nombrePadre: padre.nombre,
      plan: suscripcion.tipoPlan,
      consultasUsadas: suscripcion.consultasUsadas,
      consultasRestantes: suscripcion.consultasRestantes,
      totalTareas: tareas.length,
      tareasCompletadas: tareas.filter((t) => t.estado === EstadoTarea.COMPLETADA).length,
      cantidadHijos: padre.hijos.length,
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  //   MÉTODOS PRIVADOS — BÚSQUEDA CON VALIDACIÓN
  // ═══════════════════════════════════════════════════════════════════

  private buscarPadre(padreId: string): Padre {
    const padre = this.padres.get(padreId);
    if (!padre) {
      throw new Error(`Padre con ID "${padreId}" no encontrado.`);
    }
    return padre;
  }

  private buscarTarea(tareaId: string): Tarea {
    const tarea = this.tareas.get(tareaId);
    if (!tarea) {
      throw new Error(`Tarea con ID "${tareaId}" no encontrada.`);
    }
    return tarea;
  }

  private buscarSuscripcion(padreId: string): Suscripcion {
    const suscripcion = this.suscripciones.get(padreId);
    if (!suscripcion) {
      throw new Error(`Suscripción para el padre "${padreId}" no encontrada.`);
    }
    return suscripcion;
  }
}

// ── Tipo auxiliar para el resumen de uso ─────────────────────────────
export interface ResumenUso {
  nombrePadre: string;
  plan: TipoPlan;
  consultasUsadas: number;
  consultasRestantes: number;
  totalTareas: number;
  tareasCompletadas: number;
  cantidadHijos: number;
}

