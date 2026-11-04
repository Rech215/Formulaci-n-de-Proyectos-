import { ViewComponent } from './ViewComponent';
import { Router } from '../router/Router';

interface ProblemState {
  tarjetasVisibles: boolean;
}

export class ProblemView extends ViewComponent<ProblemState> {
  constructor() {
    super('El Problema', '/problema', { tarjetasVisibles: false });
  }

  protected onMount(): void {
    setTimeout(() => {
      this.actualizarEstado({ tarjetasVisibles: true });
    }, 100);

    this.registrarEvento('#ver-solucion', 'click', (e: Event) => {
      e.preventDefault();
      Router.obtenerInstancia().navegarA('/como-funciona');
    });
  }

  protected render(): string {
    const visible = this.obtenerEstado('tarjetasVisibles');

    return `
      <section class="py-24 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

          <div class="text-center max-w-3xl mx-auto mb-16">
            <span class="text-red-500 font-semibold tracking-wider uppercase text-sm">El problema</span>
            <h2 class="text-3xl md:text-4xl font-bold text-slate-900 mb-4 mt-2">
              La hora de la tarea no debería ser una batalla
            </h2>
            <p class="text-lg text-slate-600">
              Sabemos que quieres ayudar a tu hijo, pero la educación ha cambiado.
            </p>
          </div>

          <div class="grid md:grid-cols-3 gap-8">

            <div class="bg-slate-50 p-8 rounded-2xl border border-slate-100 hover:shadow-lg transition-all duration-500 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'}">
              <div class="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
              </div>
              <h3 class="text-xl font-bold text-slate-900 mb-3">Métodos Desconocidos</h3>
              <p class="text-slate-600">
                Las escuelas de hoy enseñan matemáticas y otras materias de forma distinta
                a como tú aprendiste. Es fácil sentirse perdido.
              </p>
            </div>

            <div class="bg-slate-50 p-8 rounded-2xl border border-slate-100 hover:shadow-lg transition-all duration-500 delay-100 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'}">
              <div class="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
                </svg>
              </div>
              <h3 class="text-xl font-bold text-slate-900 mb-3">Momentos de Tensión</h3>
              <p class="text-slate-600">
                Al intentar explicar a tu manera, el niño se confunde con lo que dijo su maestro.
                Lo que debería ser convivencia termina en discusión.
              </p>
            </div>

            <div class="bg-slate-50 p-8 rounded-2xl border border-slate-100 hover:shadow-lg transition-all duration-500 delay-200 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'}">
              <div class="w-12 h-12 bg-brand-100 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-6 h-6 text-brand-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                </svg>
              </div>
              <h3 class="text-xl font-bold text-slate-900 mb-3">Dar la respuesta no ayuda</h3>
              <p class="text-slate-600">
                Darles el resultado rápido alivia el estrés temporal, pero perjudica
                su aprendizaje a largo plazo y su confianza.
              </p>
            </div>

          </div>

          <div class="text-center mt-16">
            <button id="ver-solucion"
              class="bg-brand-600 hover:bg-brand-700 text-white px-8 py-4 rounded-full font-semibold text-lg transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-1 cursor-pointer">
              Ver cómo lo solucionamos →
            </button>
          </div>

        </div>
      </section>
    `;
  }
}
