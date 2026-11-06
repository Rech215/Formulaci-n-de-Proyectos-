import mongoose from 'mongoose';

/**
 * Conexión a MongoDB.
 *
 * La URI se registra sin credenciales para evitar filtrar secretos en logs.
 */
export async function conectarBaseDeDatos(uri, logger) {
  mongoose.set('strictQuery', true);

  await mongoose.connect(uri, {
    serverSelectionTimeoutMS: 10000,
  });

  const destino = uri.replace(/\/\/[^@]+@/, '//***@');
  logger.info({ destino }, 'Conexión a MongoDB establecida');

  mongoose.connection.on('error', (error) => {
    logger.error({ error: error.message }, 'Error de conexión con MongoDB');
  });

  return mongoose.connection;
}

export async function desconectarBaseDeDatos(logger) {
  await mongoose.disconnect();
  logger.info('Conexión a MongoDB cerrada');
}
