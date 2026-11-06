import { z } from 'zod';
import { AppError } from '../../domain/errors.js';

const schemaResultado = z.object({
  materia: z.string().trim().min(1).max(120),
  temaDetectado: z.string().trim().min(1).max(240),
  metodoSEP: z.string().trim().min(20).max(2000),
  preguntasGuia: z
    .array(z.string().trim().min(10).max(320))
    .length(3, 'El modelo debe devolver exactamente 3 preguntas guía.'),
});

const PATRONES_FUGA = [
  /la\s+respuesta\s+(?:final\s+)?(?:es|correcta\s+es)\b/i,
  /el\s+resultado\s+(?:final\s+)?es\b/i,
  /la\s+soluci[oó]n\s+es\b/i,
  /respuesta\s+correcta\s*:/i,
  /therefore,?\s+the\s+answer\s+is\b/i,
];

function contieneRespuestaFinal(resultado) {
  return resultado.preguntasGuia.some((pregunta) =>
    PATRONES_FUGA.some((patron) => patron.test(pregunta)),
  );
}

function extraerJson(texto) {
  const limpio = String(texto ?? '')
    .replace(/^\s*```(?:json)?\s*/i, '')
    .replace(/\s*```\s*$/i, '')
    .trim();

  const inicio = limpio.indexOf('{');
  const fin = limpio.lastIndexOf('}');
  if (inicio === -1 || fin === -1 || fin <= inicio) {
    throw new AppError(
      'La IA devolvió una respuesta que no contiene JSON válido.',
      { status: 502, code: 'RESPUESTA_IA_INVALIDA' },
    );
  }

  try {
    return JSON.parse(limpio.slice(inicio, fin + 1));
  } catch {
    throw new AppError('La IA devolvió JSON mal formado.', {
      status: 502,
      code: 'RESPUESTA_IA_INVALIDA',
    });
  }
}

/**
 * Valida y normaliza la respuesta del modelo.
 * Lanza 502 si el modelo incumple el contrato o intenta revelar la respuesta.
 */
export function parsearResultadoIA(texto) {
  const crudo = extraerJson(texto);
  const validado = schemaResultado.safeParse(crudo);

  if (!validado.success) {
    const detalles = validado.error.issues.map((issue) => ({
      campo: issue.path.join('.'),
      mensaje: issue.message,
    }));
    throw new AppError(
      'La IA devolvió un resultado incompleto. Intenta de nuevo con otra foto.',
      {
        status: 502,
        code: 'RESPUESTA_IA_INVALIDA',
        details: detalles,
      },
    );
  }

  if (contieneRespuestaFinal(validado.data)) {
    throw new AppError(
      'La IA intentó revelar una respuesta final. Por seguridad pedagógica, '
      + 'la respuesta fue descartada. Intenta de nuevo.',
      { status: 502, code: 'RESPUESTA_IA_NO_PERMITIDA' },
    );
  }

  return {
    materia: validado.data.materia,
    temaDetectado: validado.data.temaDetectado,
    metodoSEP: validado.data.metodoSEP,
    preguntasGuia: validado.data.preguntasGuia,
  };
}

export { schemaResultado };
