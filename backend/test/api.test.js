import assert from 'node:assert/strict';
import test from 'node:test';

import pino from 'pino';
import request from 'supertest';

import { crearApp } from '../src/app.js';

const paso = (_req, _res, next) => next();

const contenedor = {
  authService: {
    verificarToken() {
      return { sub: '507f1f77bcf86cd799439011' };
    },
    async registrar() {
      throw new Error('no usado');
    },
    async iniciarSesion() {
      throw new Error('no usado');
    },
  },
  padreRepository: {
    async buscarPorId() {
      return null;
    },
  },
  hijoRepository: {},
  tareaService: {},
  suscripcionService: {},
  consultaRepository: {},
  revenueCatClient: { configurado: false },
};

function crearAplicacion() {
  return crearApp({
    contenedor,
    logger: pino({ level: 'silent' }),
    esProduccion: false,
    corsOrigin: '*',
    maxImageMb: 10,
    webhookSecret: '',
    rateLimits: { global: paso, auth: paso, analisis: paso },
  });
}

test('responde el estado de salud', async () => {
  const respuesta = await request(crearAplicacion()).get('/api/salud');

  assert.equal(respuesta.status, 200);
  assert.equal(respuesta.body.estado, 'ok');
});

test('protege el análisis de tareas con JWT', async () => {
  const respuesta = await request(crearAplicacion())
    .post('/api/tareas/analizar')
    .field('nombreHijo', 'Sofía');

  assert.equal(respuesta.status, 401);
  assert.equal(respuesta.body.error.code, 'NO_AUTORIZADO');
});

test('valida el cuerpo del registro antes del controlador', async () => {
  const respuesta = await request(crearAplicacion())
    .post('/api/auth/registro')
    .send({ correo: 'no-es-correo' });

  assert.equal(respuesta.status, 422);
  assert.equal(respuesta.body.error.code, 'DATOS_INVALIDOS');
});

test('devuelve un error uniforme en rutas inexistentes', async () => {
  const respuesta = await request(crearAplicacion()).get('/api/no-existe');

  assert.equal(respuesta.status, 404);
  assert.equal(respuesta.body.error.code, 'NO_ENCONTRADO');
});
