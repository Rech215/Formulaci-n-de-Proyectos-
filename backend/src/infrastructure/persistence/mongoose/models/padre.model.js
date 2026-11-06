import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const PadreSchema = new Schema(
  {
    nombre: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 120,
    },
    correo: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 254,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    plan: {
      type: String,
      enum: ['GRATUITO', 'PREMIUM'],
      default: 'GRATUITO',
      index: true,
    },
    revenueCatAppUserId: {
      type: String,
      default: null,
      index: true,
      sparse: true,
    },
    fechaRegistro: {
      type: Date,
      default: Date.now,
    },
  },
  {
    versionKey: false,
    toJSON: {
      transform: (_documento, retorno) => {
        delete retorno.passwordHash;
        return retorno;
      },
    },
  },
);

PadreSchema.index({ correo: 1 }, { unique: true });

export const PadreModel = model('Padre', PadreSchema);
