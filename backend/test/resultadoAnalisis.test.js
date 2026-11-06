import assert from 'node:assert/strict';
import test from 'node:test';

import { AppError } from '../src/domain/errors.js';
import { parsearResultadoIA } from '../src/infrastructure/ai/resultadoAnalisis.validator.js';

const resultadoValido = {
  materia: 'Matemáticas',
  temaDetectado: 'Fracciones equivalentes',
  metodoSEP: 'La SEP parte de material concreto y representaciones gráficas.',
  preguntasGuia: [
    '¿Qué representa cada parte del dibujo?',
    '¿Puedes explicarlo con un objeto de casa?',
    '¿Qué cambiaría si divides cada parte a la mitad?',
  ],
};

test('acepta un resultado con el contrato exacto', () => {
  const resultado = parsearResultadoIA(JSON.stringify(resultadoValido));

  assert.equal(resultado.materia, 'Matemáticas');
  assert.equal(resultado.preguntasGuia.length, 3);
});

test('extrae el JSON aunque venga dentro de un bloque de código', () => {
  const texto = `\`\`\`json\n${JSON.stringify(resultadoValido)}\n\`\`\``;
  const resultado = parsearResultadoIA(texto);

  assert.equal(resultado.temaDetectado, 'Fracciones equivalentes');
});

test('rechaza respuestas que revelan el resultado final', () => {
  const conFuga = {
    ...resultadoValido,
    preguntasGuia: [
      'La respuesta final es 1/2, ¿la ves?',
      '¿Puedes explicarlo con un objeto de casa?',
      '¿Qué cambiaría si divides cada parte a la mitad?',
    ],
  };

  assert.throws(
    () => parsearResultadoIA(JSON.stringify(conFuga)),
    (error) => error instanceof AppError
      && error.code === 'RESPUESTA_IA_NO_PERMITIDA',
  );
});

test('rechaza resultados incompletos', () => {
  const incompleto = { ...resultadoValido, preguntasGuia: ['Solo una'] };

  assert.throws(
    () => parsearResultadoIA(JSON.stringify(incompleto)),
    (error) => error instanceof AppError
      && error.code === 'RESPUESTA_IA_INVALIDA',
  );
});
