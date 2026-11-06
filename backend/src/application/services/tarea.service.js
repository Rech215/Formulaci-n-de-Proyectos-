import { AppError } from '../../domain/errors.js';

/**
 * Orquesta el análisis de una tarea escolar.
 *
 * Orden de operaciones:
 *  1. Reserva atómica de la consulta (límite de 5 tareas del plan gratuito).
 *  2. Saneamiento de la imagen en memoria (sin EXIF, sin disco).
 *  3. Llamada al proveedor multimodal con el system prompt estricto.
 *  4. Validación del contrato JSON y detección de fugas de respuesta.
 *  5. Persistencia únicamente del resultado pedagógico.
 *
 * Si algo falla antes de guardar, la reserva se libera para no cobrarle al
 * usuario una consulta que no produjo resultado. Los buffers se sobrescriben
 * con ceros en `finally` para no dejar rastros de la tarea del menor.
 */
export function crearTareaService({
  suscripcionService,
  consultaRepository,
  proveedorIA,
  construirSystemPrompt,
  construirPromptUsuario,
  parsearResultadoIA,
  sanearImagen,
}) {
  return {
    async analizar({
      padre,
      hijo,
      materiaSugerida = '',
      imagen,
      mimeType,
    }) {
      if (!Buffer.isBuffer(imagen) || imagen.length === 0) {
        throw new AppError('La imagen de la tarea es obligatoria.', {
          status: 422,
          code: 'IMAGEN_REQUERIDA',
        });
      }

      const reserva = await suscripcionService.reservarConsulta(padre);
      const inicio = Date.now();
      let resultadoGuardado = false;

      try {
        const saneada = await sanearImagen(imagen, mimeType);

        try {
          const systemPrompt = construirSystemPrompt({
            gradoEscolar: hijo.gradoEscolar,
            edadHijo: hijo.edad,
            materiaSugerida,
          });
          const userPrompt = construirPromptUsuario({ materiaSugerida });

          const textoSinValidar = await proveedorIA.analizarImagen({
            imagen: saneada.buffer,
            mimeType: saneada.mimeType,
            systemPrompt,
            userPrompt,
          });

          const resultado = parsearResultadoIA(textoSinValidar);

          const consulta = await consultaRepository.crear({
            padreId: padre._id,
            hijoId: hijo._id,
            nombreHijo: hijo.nombre,
            gradoEscolar: hijo.gradoEscolar,
            edadHijo: hijo.edad,
            materia: resultado.materia,
            temaDetectado: resultado.temaDetectado,
            metodoSEP: resultado.metodoSEP,
            preguntasGuia: resultado.preguntasGuia,
            estado: 'COMPLETADA',
            modeloIA: proveedorIA.modelo,
            duracionMs: Date.now() - inicio,
          });

          resultadoGuardado = true;
          return consulta;
        } finally {
          saneada.buffer.fill(0);
        }
      } catch (error) {
        if (!resultadoGuardado) {
          await suscripcionService.liberarConsulta(reserva);
        }
        throw error;
      } finally {
        imagen.fill(0);
      }
    },
  };
}
