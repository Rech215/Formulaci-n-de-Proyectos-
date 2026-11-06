import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const HijoSchema = new Schema(
  {
    padreId: {
      type: Schema.Types.ObjectId,
      ref: 'Padre',
      required: true,
      index: true,
    },
    nombre: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 80,
    },
    nombreNormalizado: {
      type: String,
      required: true,
      maxlength: 80,
    },
    edad: {
      type: Number,
      required: true,
      min: 3,
      max: 18,
    },
    gradoEscolar: {
      type: String,
      required: true,
      trim: true,
      maxlength: 80,
    },
    creadoEn: {
      type: Date,
      default: Date.now,
    },
  },
  { versionKey: false },
);

HijoSchema.index({ padreId: 1, nombreNormalizado: 1 }, { unique: true });

export const HijoModel = model('Hijo', HijoSchema);
