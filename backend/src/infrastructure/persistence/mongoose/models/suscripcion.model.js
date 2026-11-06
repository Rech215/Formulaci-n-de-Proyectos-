import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const SuscripcionSchema = new Schema(
  {
    padreId: {
      type: Schema.Types.ObjectId,
      ref: 'Padre',
      required: true,
      unique: true,
      index: true,
    },
    plan: {
      type: String,
      enum: ['GRATUITO', 'PREMIUM'],
      default: 'GRATUITO',
    },
    estado: {
      type: String,
      enum: ['ACTIVA', 'CANCELADA', 'EXPIRADA'],
      default: 'ACTIVA',
    },
    proveedor: {
      type: String,
      enum: ['NONE', 'REVENUECAT'],
      default: 'NONE',
    },
    revenueCatAppUserId: {
      type: String,
      default: null,
      index: true,
      sparse: true,
    },
    entitlementId: {
      type: String,
      default: '',
    },
    fechaInicio: {
      type: Date,
      default: Date.now,
    },
    fechaRenovacion: {
      type: Date,
      default: null,
    },
    actualizadoEn: {
      type: Date,
      default: Date.now,
    },
  },
  { versionKey: false },
);

export const SuscripcionModel = model('Suscripcion', SuscripcionSchema);
