import { z } from 'zod';

const texto = (min, max) => z.string().trim().min(min).max(max);

export const hijoSchema = z
  .object({
    nombre: texto(2, 80),
    edad: z.coerce.number().int().min(3).max(18),
    gradoEscolar: texto(1, 80),
  })
  .strict();

export const registroSchema = z
  .object({
    nombre: texto(2, 120),
    correo: z.string().trim().email().max(254).toLowerCase(),
    password: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres.').max(128),
    hijos: z.array(hijoSchema).max(10).default([]),
  })
  .strict();

export const loginSchema = z
  .object({
    correo: z.string().trim().email().max(254).toLowerCase(),
    password: z.string().min(1).max(128),
  })
  .strict();

export const analizarTareaSchema = z
  .object({
    nombreHijo: texto(2, 80),
    materiaSugerida: z.string().trim().max(120).optional().default(''),
  })
  .strict();

export const hijoParametroSchema = z
  .object({
    hijoId: z.string().trim().min(1).max(120),
  })
  .strict();

export const hijoNombreQuerySchema = z
  .object({
    nombre: texto(2, 80),
  })
  .strict();
