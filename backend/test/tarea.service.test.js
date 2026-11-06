import assert from 'node:assert/strict';
import test from 'node:test';

import { crearTareaService } from '../src/application/services/tarea.service.js';

const resultadoIA = JSON.stringify({
  materia: 'Español',
  temaDetectado: 'Idea principal',
  metodoSEP: 'Lectura guiada y preguntas abiertas antes de subrayar.',
  preguntasGuia: [
    '¿De qué trata el texto con tus palabras?',
    '¿Cuál es la parte más importante y por qué?',
    '¿Qué palabra no entiendes y qué crees que significa?',
  ],
});

function crearServicio({ fallaIA = false } = {}) {
  const estado = {
    reservas: 0,
    liberaciones: 0,
    datosGuardados: null,
    bufferSaneado: null,
  };

  const service = crearTareaService({
    suscripcionService: {
      async reservarConsulta() {
        estado.reservas += 1;
        return { padreId: 'padre1', periodo: '2026-11' };
      },
      async liberarConsulta() {
        estado.liberaciones += 1;
      },
    },
    consultaRepository: {
      async crear(datos) {
        estado.datosGuardados = datos;
        return { _id: 'consulta1', ...datos, creadoEn: new Date() };
      },
    },
    proveedorIA: {
      modelo: 'modelo-falso',
      async analizarImagen({ imagen }) {
        if (fallaIA) {
          throw new Error('proveedor no disponible');
        }
        assert.ok(imagen.length > 0);
        return resultadoIA;
      },
    },
    construirSystemPrompt: () => 'system prompt',
    construirPromptUsuario: () => 'user prompt',
    parsearResultadoIA: (texto) => JSON.parse(texto),
    async sanearImagen(buffer) {
      const saneada = Buffer.from(buffer);
      estado.bufferSaneado = saneada;
      return { buffer: saneada, mimeType: 'image/jpeg' };
    },
  });

  return { service, estado };
}

const padre = { _id: 'padre1' };
const hijo = {
  _id: 'hijo1',
  nombre: 'Sofía',
  gradoEscolar: '3ro Primaria',
  edad: 8,
};

test('analiza, guarda solo el resultado pedagógico y borra la imagen', async () => {
  const { service, estado } = crearServicio();
  const imagen = Buffer.alloc(64, 7);

  const consulta = await service.analizar({
    padre,
    hijo,
    materiaSugerida: 'Español',
    imagen,
    mimeType: 'image/jpeg',
  });

  assert.equal(consulta.materia, 'Español');
  assert.equal(estado.reservas, 1);
  assert.equal(estado.liberaciones, 0);
  assert.ok(imagen.equals(Buffer.alloc(64)), 'el buffer original debe quedar en ceros');
  assert.ok(
    estado.bufferSaneado.equals(Buffer.alloc(64)),
    'el buffer saneado debe quedar en ceros',
  );
  assert.equal('imagen' in estado.datosGuardados, false);
  assert.equal('imagenUrl' in estado.datosGuardados, false);
  assert.deepEqual(estado.datosGuardados.preguntasGuia.length, 3);
});

test('si la IA falla, libera la consulta y no deja rastros de la imagen', async () => {
  const { service, estado } = crearServicio({ fallaIA: true });
  const imagen = Buffer.alloc(32, 9);

  await assert.rejects(
    service.analizar({
      padre,
      hijo,
      imagen,
      mimeType: 'image/jpeg',
    }),
    /proveedor no disponible/,
  );

  assert.equal(estado.liberaciones, 1);
  assert.equal(estado.datosGuardados, null);
  assert.ok(imagen.equals(Buffer.alloc(32)));
});
