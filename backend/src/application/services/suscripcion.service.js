import {
  ESTADO_SUSCRIPCION,
  LIMITE_CONSULTAS_GRATUITO,
  esPlanPremium,
  estaSuscripcionVigente,
  limiteDelPlan,
  periodoActual,
} from '../../domain/suscripcion.js';
import { AppError, LimitePlanError } from '../../domain/errors.js';
import { serializarSuscripcion } from '../serializers.js';

function idDe(padre) {
  return padre?._id?.toString() ?? padre?.id;
}

export function crearSuscripcionService({
  padreRepository,
  suscripcionRepository,
  usoRepository,
}) {
  return {
    async obtener(padreId) {
      const [suscripcion, uso] = await Promise.all([
        suscripcionRepository.obtenerOCrear(padreId),
        usoRepository.obtener({ padreId, periodo: periodoActual() }),
      ]);
      return serializarSuscripcion(suscripcion, uso, padreId);
    },

    async reservarConsulta(padre) {
      const padreId = idDe(padre);
      const suscripcion = await suscripcionRepository.obtenerOCrear(padreId);

      if (!estaSuscripcionVigente(suscripcion)) {
        throw new LimitePlanError(
          'Tu suscripción no está activa. Renueva tu plan para continuar.',
        );
      }

      const plan = suscripcion.plan ?? 'GRATUITO';
      const limite = limiteDelPlan(plan);
      const periodo = periodoActual();
      const reserva = await usoRepository.reservar({
        padreId,
        periodo,
        limite,
      });

      if (!reserva.permitido) {
        throw new LimitePlanError(
          `Has alcanzado el límite de ${LIMITE_CONSULTAS_GRATUITO} tareas `
          + 'del plan gratuito este mes. Actualiza a Premium para continuar.',
        );
      }

      return {
        padreId,
        periodo,
        plan,
        limite,
        contador: reserva.contador,
      };
    },

    async liberarConsulta(reserva) {
      if (!reserva) return;
      await usoRepository.liberar({
        padreId: reserva.padreId,
        periodo: reserva.periodo,
      });
    },

    async aplicarEstadoRevenueCat({
      padreId,
      appUserId,
      activo,
      fechaRenovacion = null,
    }) {
      const plan = activo ? 'PREMIUM' : 'GRATUITO';
      const estado = activo
        ? ESTADO_SUSCRIPCION.ACTIVA
        : ESTADO_SUSCRIPCION.EXPIRADA;

      const suscripcion = await suscripcionRepository.actualizarPorPadre(
        padreId,
        {
          plan,
          estado,
          proveedor: 'REVENUECAT',
          revenueCatAppUserId: appUserId,
          entitlementId: activo ? 'premium' : '',
          fechaRenovacion: fechaRenovacion
            ? new Date(fechaRenovacion)
            : null,
        },
      );

      await padreRepository.actualizarPlan(padreId, plan);
      await padreRepository.vincularRevenueCat(padreId, appUserId);

      const uso = await usoRepository.obtener({
        padreId,
        periodo: periodoActual(),
      });

      return serializarSuscripcion(suscripcion, uso, padreId);
    },

    async resumen(padre, { totalTareas, tareasCompletadas, cantidadHijos }) {
      const padreId = idDe(padre);
      const [suscripcion, uso] = await Promise.all([
        suscripcionRepository.obtenerOCrear(padreId),
        usoRepository.obtener({ padreId, periodo: periodoActual() }),
      ]);
      const publica = serializarSuscripcion(suscripcion, uso, padreId);
      return {
        nombrePadre: padre.nombre,
        plan: publica.tipoPlan,
        consultasUsadas: publica.consultasUsadas,
        consultasRestantes: publica.consultasRestantes,
        totalTareas,
        tareasCompletadas,
        cantidadHijos,
      };
    },

    async validarAccesoPremium(padreId) {
      const suscripcion = await suscripcionRepository.obtenerPorPadre(padreId);
      if (!suscripcion || !esPlanPremium(suscripcion.plan)) {
        throw new AppError('Esta función requiere el plan Premium.', {
          status: 402,
          code: 'REQUIERE_PREMIUM',
        });
      }
      return suscripcion;
    },

    limiteDelPlan,
  };
}
