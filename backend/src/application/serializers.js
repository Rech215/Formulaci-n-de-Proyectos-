function idDe(documento) {
  return documento?._id?.toString() ?? documento?.id ?? '';
}

function isoOFechaNula(fecha) {
  return fecha ? new Date(fecha).toISOString() : null;
}

/**
 * Formato consumido por la app Flutter (`Padre.fromJson`).
 * No incluye passwordHash ni otros datos sensibles.
 */
export function serializarPadre(padre, hijos) {
  return {
    id: idDe(padre),
    nombre: padre.nombre,
    correo: padre.correo,
    hijos: (hijos ?? []).map((hijo) => ({
      id: idDe(hijo),
      nombre: hijo.nombre,
      edad: hijo.edad,
      gradoEscolar: hijo.gradoEscolar,
    })),
    planActual: padre.plan ?? 'GRATUITO',
    fechaRegistro: isoOFechaNula(padre.fechaRegistro),
  };
}

export function serializarHijo(hijo) {
  return {
    id: idDe(hijo),
    nombre: hijo.nombre,
    edad: hijo.edad,
    gradoEscolar: hijo.gradoEscolar,
  };
}

/**
 * Formato consumido por `Suscripcion.fromJson` en Flutter.
 * `limiteConsultas = -1` representa consultas ilimitadas.
 */
export function serializarSuscripcion(suscripcion, uso, padreId) {
  const plan = suscripcion?.plan ?? 'GRATUITO';
  const esPremium = plan === 'PREMIUM';
  const consultasUsadas = uso?.contador ?? 0;

  return {
    id: idDe(suscripcion),
    padreId: padreId?.toString() ?? idDe(suscripcion),
    tipoPlan: plan,
    estado: suscripcion?.estado ?? 'ACTIVA',
    consultasUsadas,
    limiteConsultas: -1,
    consultasRestantes: null,
    esPremium,
    fechaInicio: isoOFechaNula(suscripcion?.fechaInicio ?? new Date()),
    fechaRenovacion: isoOFechaNula(suscripcion?.fechaRenovacion),
  };
}

/**
 * Formato consumido por `Tarea.fromJson` en Flutter.
 * La imagen no existe en el servidor: `imagenUrl` es solo una marca de
 * privacidad para que la app sepa que no hay archivo retenido.
 */
export function serializarConsulta(consulta) {
  return {
    id: idDe(consulta),
    padreId: consulta.padreId?.toString() ?? '',
    imagenUrl: 'memoria://no-retenida',
    nombreHijo: consulta.nombreHijo ?? '',
    estado: consulta.estado ?? 'COMPLETADA',
    materia: consulta.materia,
    temaDetectado: consulta.temaDetectado,
    metodoSEP: consulta.metodoSEP,
    preguntasGuia: consulta.preguntasGuia ?? [],
    fechaCreacion: isoOFechaNula(consulta.creadoEn ?? new Date()),
    mensajeError: null,
  };
}

export function serializarResumenUso({
  padre,
  suscripcion,
  uso,
  totalTareas,
  tareasCompletadas,
  cantidadHijos,
}) {
  const publica = serializarSuscripcion(suscripcion, uso, padre?._id);
  return {
    nombrePadre: padre?.nombre ?? '',
    plan: publica.tipoPlan,
    consultasUsadas: publica.consultasUsadas,
    consultasRestantes: publica.consultasRestantes,
    totalTareas,
    tareasCompletadas,
    cantidadHijos,
  };
}
