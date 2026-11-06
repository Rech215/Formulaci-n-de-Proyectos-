import mongoose from 'mongoose';

const { Schema, model } = mongoose;

/**
 * Registro de una consulta pedagógica.
 *
 * PRIVACIDAD: aquí NO se guarda la fotografía, ni el buffer, ni una URL de
 * imagen, ni el nombre del menor como dato obligatorio. Solo se persiste el
 * resultado pedagógico y metadatos mínimos para el historial y el límite del
 * plan gratuito.
 */
const ConsultaSchema = new Schema(
  {
    padreId: {
      type: Schema.Types.ObjectId,
      ref: 'Padre',
      required: true,
      index: true,
    },
    hijoId: {
      type: Schema.Types.ObjectId,
      ref: 'Hijo',
      default: null,
      index: true,
    },
    nombreHijo: {
      type: String,
      trim: true,
      maxlength: 80,
      default: '',
    },
    gradoEscolar: {
      type: String,
      trim: true,
      maxlength: 80,
      default: '',
    },
    edadHijo: {
      type: Number,
      min: 3,
      max: 18,
      default: null,
    },
    materia: {
      type: String,
      required: true,
      trim: true,
      maxlength: 120,
    },
    temaDetectado: {
      type: String,
      required: true,
      trim: true,
      maxlength: 240,
    },
    metodoSEP: {
      type: String,
      required: true,
      trim: true,
      maxlength: 2000,
    },
    preguntasGuia: {
      type: [String],
      required: true,
      validate: {
        validator: (preguntas) => preguntas.length === 3,
        message: 'Deben registrarse exactamente 3 preguntas guía.',
      },
    },
    estado: {
      type: String,
      enum: ['COMPLETADA', 'ERROR'],
      default: 'COMPLETADA',
      index: true,
    },
    modeloIA: {
      type: String,
      default: '',
    },
    duracionMs: {
      type: Number,
      min: 0,
      default: 0,
    },
    creadoEn: {
      type: Date,
      default: Date.now,
      index: true,
    },
  },
  { versionKey: false },
);

ConsultaSchema.index({ padreId: 1, creadoEn: -1 });

export const ConsultaModel = model('Consulta', ConsultaSchema);
