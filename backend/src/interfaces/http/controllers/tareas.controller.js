import { serializarConsulta } from '../../../application/serializers.js';
import { AppError, NoEncontradoError } from '../../../domain/errors.js';

export function crearTareasController({
  tareaService,
  suscripcionService,
  hijoRepository,
  consultaRepository,
}) {
  return {
    async analizar(req, res) {
      const imagen = req.file?.buffer;

      try {
        if (!imagen) {
          throw new AppError('La imagen de la tarea es obligatoria.', {
            status: 422,
            code: 'IMAGEN_REQUERIDA',
          });
        }

        const { nombreHijo, materiaSugerida } = req.body;
        const hijo = await hijoRepository.buscarPorNombre(
          req.padre._id,
          nombreHijo,
        );

        if (!hijo) {
          throw new NoEncontradoError(
            `No encontramos a "${nombreHijo}" en tu cuenta. `
            + 'Agrégalo como hijo antes de analizar la tarea.',
          );
        }

        const consulta = await tareaService.analizar({
          padre: req.padre,
          hijo,
          materiaSugerida,
          imagen,
          mimeType: req.file.mimetype,
        });

        const suscripcion = await suscripcionService.obtener(req.padre._id);

        return res.status(201).json({
          tarea: serializarConsulta(consulta),
          suscripcion,
        });
      } finally {
        if (Buffer.isBuffer(imagen)) {
          imagen.fill(0);
        }
      }
    },

    async listar(req, res) {
      const limite = Math.min(Number(req.query.limite) || 50, 100);
      const salto = Math.max(Number(req.query.salto) || 0, 0);

      const consultas = await consultaRepository.listarPorPadre(
        req.padre._id,
        { limite, salto },
      );

      return res.json({
        tareas: consultas.map(serializarConsulta),
      });
    },

    async obtener(req, res) {
      const consulta = await consultaRepository.buscarPorIdYPadre(
        req.params.tareaId,
        req.padre._id,
      );

      if (!consulta) {
        throw new NoEncontradoError('No encontramos esa tarea en tu historial.');
      }

      return res.json({ tarea: serializarConsulta(consulta) });
    },

    async resumen(req, res) {
      const [totalTareas, tareasCompletadas, cantidadHijos] = await Promise.all([
        consultaRepository.contarPorPadre(req.padre._id),
        consultaRepository.contarCompletadas(req.padre._id),
        hijoRepository.contarPorPadre(req.padre._id),
      ]);

      const resumen = await suscripcionService.resumen(req.padre, {
        totalTareas,
        tareasCompletadas,
        cantidadHijos,
      });

      return res.json({ resumen });
    },
  };
}
