import mongoose from 'mongoose';

const { Schema, model } = mongoose;

/**
 * Contador atómico de consultas por padre y periodo (YYYY-MM).
 * Permite aplicar el límite de 5 tareas del plan gratuito sin carreras.
 */
const UsoMensualSchema = new Schema(
  {
    padreId: {
      type: Schema.Types.ObjectId,
      ref: 'Padre',
      required: true,
      index: true,
    },
    periodo: {
      type: String,
      required: true,
      match: /^\d{4}-\d{2}$/,
    },
    contador: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
  },
  { versionKey: false },
);

UsoMensualSchema.index({ padreId: 1, periodo: 1 }, { unique: true });

export const UsoMensualModel = model('UsoMensual', UsoMensualSchema);
