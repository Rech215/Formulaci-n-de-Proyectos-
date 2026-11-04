/**
 * FooterComponent — Pie de página persistente de la SPA.
 */

export class FooterComponent {
  private _contenedor: HTMLElement | null;

  constructor() {
    this._contenedor = null;
  }

  montar(contenedorId: string): void {
    this._contenedor = document.getElementById(contenedorId);
    if (!this._contenedor) return;

    this._contenedor.innerHTML = `
      <footer class="bg-slate-950 text-slate-400 py-12 border-t border-slate-900">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex flex-col md:flex-row justify-between items-center gap-6">
            <a href="#/inicio" class="flex items-center gap-2 no-underline">
              <div class="w-8 h-8 bg-brand-500 rounded flex items-center justify-center text-white font-bold text-lg">
                E
              </div>
              <span class="font-bold text-xl text-white">EduGuía</span>
            </a>

            <div class="flex space-x-6 text-sm">
              <a href="#" class="hover:text-white transition-colors no-underline text-slate-400">Términos de Servicio</a>
              <a href="#" class="hover:text-white transition-colors no-underline text-slate-400">Privacidad de Datos (Menores)</a>
              <a href="#" class="hover:text-white transition-colors no-underline text-slate-400">Contacto</a>
            </div>
          </div>
          <div class="mt-8 text-center text-sm border-t border-slate-800 pt-8">
            <p>&copy; 2026 Formulación de Proyectos - Equipo UTM (Cristian, Rolando, Reily, Jose). Todos los derechos reservados.</p>
          </div>
        </div>
      </footer>
    `;
  }
}

