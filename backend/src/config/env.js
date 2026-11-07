import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'test', 'production'])
    .default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  CORS_ORIGIN: z.string().default('*'),
  MONGODB_URI: z.string().min(1, 'MONGODB_URI es obligatorio.'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET debe tener al menos 32 caracteres.'),
  JWT_EXPIRES_IN: z.string().default('30d'),
  GEMINI_API_KEY: z.string().min(1, 'GEMINI_API_KEY es obligatorio.'),
  GEMINI_MODEL: z.string().default('gemini-2.0-flash'),
  AI_TIMEOUT_MS: z.coerce.number().int().positive().default(60000),
  MAX_IMAGE_MB: z.coerce.number().positive().default(10),
  REVENUECAT_SECRET_KEY: z.string().optional().default(''),
  REVENUECAT_ENTITLEMENT_ID: z.string().default('premium'),
  REVENUECAT_WEBHOOK_SECRET: z.string().optional().default(''),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const detalles = parsed.error.issues
    .map((issue) => `  - ${issue.path.join('.')}: ${issue.message}`)
    .join('\n');
  throw new Error(`Configuración inválida de variables de entorno:\n${detalles}`);
}

export const env = Object.freeze(parsed.data);

export const esProduccion = env.NODE_ENV === 'production';
