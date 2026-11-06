import { GoogleGenerativeAI } from '@google/generative-ai';
import { AppError } from '../../domain/errors.js';

/**
 * Proveedor de IA multimodal (Gemini) con timeout y sin persistencia.
 * El buffer de la imagen sólo vive durante la llamada y es liberado por el
 * controlador en el bloque `finally`.
 */
export function crearProveedorGemini({ apiKey, model, timeoutMs, logger }) {
  const cliente = new GoogleGenerativeAI(apiKey);

  return {
    modelo: model,

    async analizarImagen({ imagen, mimeType, systemPrompt, userPrompt }) {
      const modelo = cliente.getGenerativeModel({
        model,
        systemInstruction: systemPrompt,
        generationConfig: {
          temperature: 0.25,
          topP: 0.9,
          maxOutputTokens: 1200,
          responseMimeType: 'application/json',
        },
      });

      const controlador = new AbortController();
      const temporizador = setTimeout(() => controlador.abort(), timeoutMs);

      try {
        const peticion = modelo.generateContent(
          [
            {
              inlineData: {
                data: imagen.toString('base64'),
                mimeType,
              },
            },
            { text: userPrompt },
          ],
          { signal: controlador.signal },
        );

        const resultado = await Promise.race([
          peticion,
          new Promise((_, rechazar) => {
            controlador.signal.addEventListener('abort', () => {
              rechazar(new Error('Tiempo de espera de la IA agotado.'));
            });
          }),
        ]);

        return resultado.response.text();
      } catch (error) {
        if (controlador.signal.aborted) {
          throw new AppError(
            'El análisis tardó demasiado. Intenta de nuevo con una foto más ligera.',
            { status: 504, code: 'IA_TIMEOUT' },
          );
        }

        logger.error(
          { error: error?.message },
          'Error al invocar el proveedor de IA',
        );
        throw new AppError(
          'No fue posible analizar la imagen en este momento. Intenta de nuevo.',
          { status: 502, code: 'IA_NO_DISPONIBLE' },
        );
      } finally {
        clearTimeout(temporizador);
      }
    },
  };
}
