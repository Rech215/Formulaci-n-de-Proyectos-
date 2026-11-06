import { serializarPadre } from '../../../application/serializers.js';

export function crearAuthController({ authService, hijoRepository }) {
  return {
    async registrar(req, res) {
      const { nombre, correo, password, hijos } = req.body;
      const { token, padre, hijos: hijosCreados } = await authService.registrar({
        nombre,
        correo,
        password,
        hijos,
      });

      return res.status(201).json({
        token,
        padre: serializarPadre(padre, hijosCreados),
      });
    },

    async iniciarSesion(req, res) {
      const { correo, password } = req.body;
      const { token, padre, hijos } = await authService.iniciarSesion({
        correo,
        password,
      });

      return res.json({
        token,
        padre: serializarPadre(padre, hijos),
      });
    },

    async perfil(req, res) {
      const hijos = await hijoRepository.listarPorPadre(req.padre._id);
      return res.json({ padre: serializarPadre(req.padre, hijos) });
    },
  };
}
