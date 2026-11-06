import { crearApp } from './app.js';
import { conectarBaseDeDatos, desconectarBaseDeDatos } from './config/database.js';
import { env, esProduccion } from './config/env.js';
import { logger } from './config/logger.js';
import { crearContenedor } from './container.js';

let servidor;
let cerrando = false;

async function iniciar() {
  await conectarBaseDeDatos(env.MONGODB_URI, logger);

  const contenedor = crearContenedor({ env, logger });
  const app = crearApp({
    contenedor,
    logger,
    esProduccion,
    corsOrigin: env.CORS_ORIGIN,
    maxImageMb: env.MAX_IMAGE_MB,
    webhookSecret: env.REVENUECAT_WEBHOOK_SECRET,
  });

  servidor = app.listen(env.PORT, () => {
    logger.info({ puerto: env.PORT }, 'API de EduGuía escuchando');
  });
}

async function cerrar(senal) {
  if (cerrando) return;
  cerrando = true;
  logger.info({ senal }, 'Cerrando la API de EduGuía');

  if (servidor) {
    await new Promise((resolve) => servidor.close(resolve));
  }

  await desconectarBaseDeDatos(logger);
  process.exit(0);
}

process.on('SIGINT', () => cerrar('SIGINT'));
process.on('SIGTERM', () => cerrar('SIGTERM'));

iniciar().catch((error) => {
  logger.error({ error: error?.message }, 'No fue posible iniciar la API');
  process.exit(1);
});
