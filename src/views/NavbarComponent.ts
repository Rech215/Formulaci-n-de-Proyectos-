/**
 * NavbarComponent — Barra de navegación persistente de la SPA.
 *
 * No extiende ViewComponent porque es un componente fijo
 * que vive fuera del contenedor del Router. Se actualiza
 * cuando el Router cambia de ruta (highlighting de la ruta activa).
 */

import { Router } from '../router/Router';

export class NavbarComponent {
  private _contenedor: HTMLElement | null;
  private _menuAbierto: boolean;

  constructor() {
    this._contenedor = null;
    this._menuAbierto = false;
  }

  /**
   * Monta el navbar en el elemento DOM especificado.
   */
  montar(contenedorId: string): void {
    this._contenedor = document.getElementById(contenedorId);
    if (!this._contenedor) {
      throw new Error(`Navbar: No se encontró el contenedor "${contenedorId}".`);
    }

    this.renderizar();
    this.bindEventos();

    // Escuchar cambios de ruta para actualizar el link activo
    Router.obtenerInstancia().alNavegar(() => {
      this.renderizar();
      this.bindEventos();
    });
  }

  private renderizar(): void {
    if (!this._contenedor) return;
    const router = Router.obtenerInstancia();
    const rutas = router.rutasRegistradas;

    this._contenedor.innerHTML = `
      <nav class="fixed w-full bg-white/90 backdrop-blur-md z-40 border-b border-slate-100 transition-all duration-300">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center h-20">

            <!-- Logo -->
            <a href="#/inicio" class="flex-shrink-0 flex items-center gap-2 cursor-pointer no-underline">
              <div class="w-10 h-10 bg-brand-500 rounded-lg flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-brand-500/30">
                E
              </div>
              <span class="font-bold text-2xl tracking-tight text-slate-900">Edu<span class="text-brand-600">Guía</span></span>
            </a>

            <!-- Desktop Menu -->
            <div class="hidden md:flex space-x-8 items-center">
              ${rutas.map((r) => {
                const activa = router.esRutaActiva(r.ruta);
                return `
                  <a href="#${r.ruta}"
                     class="nav-link font-medium transition-colors ${activa
                       ? 'text-brand-600 border-b-2 border-brand-500 pb-1'
                       : 'text-slate-600 hover:text-brand-600'}">
                    ${r.etiqueta}
                  </a>`;
              }).join('')}
            </div>

            <!-- CTA -->
            <div class="hidden md:flex">
              <a href="#/planes"
                 class="bg-brand-600 hover:bg-brand-700 text-white px-6 py-2.5 rounded-full font-semibold transition-all shadow-md hover:shadow-lg transform hover:-translate-y-0.5 no-underline">
                Probar Gratis
              </a>
            </div>

            <!-- Mobile menu button -->
            <div class="md:hidden flex items-center">
              <button id="menu-toggle" class="text-slate-600 hover:text-slate-900 focus:outline-none cursor-pointer">
                <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  ${this._menuAbierto
                    ? '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>'
                    : '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>'}
                </svg>
              </button>
            </div>

          </div>

          <!-- Mobile Menu -->
          <div class="md:hidden overflow-hidden transition-all duration-300 ${this._menuAbierto ? 'max-h-64 pb-4' : 'max-h-0'}">
            <div class="flex flex-col space-y-3 pt-2">
              ${rutas.map((r) => {
                const activa = router.esRutaActiva(r.ruta);
                return `
                  <a href="#${r.ruta}"
                     class="mobile-nav-link px-4 py-2 rounded-lg font-medium transition-colors no-underline ${activa
                       ? 'bg-brand-50 text-brand-600'
                       : 'text-slate-600 hover:bg-slate-50'}">
                    ${r.etiqueta}
                  </a>`;
              }).join('')}
              <a href="#/planes"
                 class="mx-4 py-3 bg-brand-600 text-white rounded-xl font-semibold text-center no-underline">
                Probar Gratis
              </a>
            </div>
          </div>

        </div>
      </nav>
    `;
  }

  private bindEventos(): void {
    if (!this._contenedor) return;

    // Toggle menú móvil
    const toggleBtn = this._contenedor.querySelector('#menu-toggle');
    if (toggleBtn) {
      toggleBtn.addEventListener('click', () => {
        this._menuAbierto = !this._menuAbierto;
        this.renderizar();
        this.bindEventos();
      });
    }

    // Cerrar menú al hacer click en un link móvil
    const mobileLinks = this._contenedor.querySelectorAll('.mobile-nav-link');
    mobileLinks.forEach((link) => {
      link.addEventListener('click', () => {
        this._menuAbierto = false;
      });
    });
  }
}

