import { ViewComponent } from './ViewComponent';
import { Router } from '../router/Router';

interface HomeState {
  animado: boolean;
}

export class HomeView extends ViewComponent<HomeState> {
  constructor() {
    super('Inicio', '/inicio', { animado: false });
  }

  protected onMount(): void {
    requestAnimationFrame(() => {
      this.actualizarEstado({ animado: true });
    });

    this.registrarEvento('#cta-prueba', 'click', (e: Event) => {
      e.preventDefault();
      Router.obtenerInstancia().navegarA('/planes');
    });

    this.registrarEvento('#cta-como-funciona', 'click', (e: Event) => {
      e.preventDefault();
      Router.obtenerInstancia().navegarA('/como-funciona');
    });
  }

  protected render(): string {
    const animado = this.obtenerEstado('animado');

    return `
      <section class="relative min-h-screen flex items-center overflow-hidden bg-gradient-to-b from-brand-50 to-white py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative w-full">
          <div class="grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">

            <div class="max-w-2xl transition-all duration-700 ${animado ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'}">
              <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-100 text-brand-700 font-medium text-sm mb-6">
                <span class="flex h-2 w-2 rounded-full bg-brand-500 animate-pulse"></span>
                La primera IA para padres
              </div>
              <h1 class="text-4xl md:text-5xl lg:text-6xl font-extrabold text-slate-900 leading-tight mb-6 tracking-tight">
                Acompaña su aprendizaje sin hacerle la tarea.
              </h1>
              <p class="text-lg md:text-xl text-slate-600 mb-8 leading-relaxed">
                Entiende cómo le enseñan hoy en la escuela. Nuestra IA te explica el método
                y te da las preguntas correctas para que tu hijo descubra la respuesta por sí mismo.
              </p>
              <div class="flex flex-col sm:flex-row gap-4">
                <button id="cta-prueba"
                  class="bg-brand-600 hover:bg-brand-700 text-white px-8 py-4 rounded-full font-semibold text-lg text-center transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-1 cursor-pointer">
                  Comienza tu prueba gratis
                </button>
                <button id="cta-como-funciona"
                  class="bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 px-8 py-4 rounded-full font-semibold text-lg text-center transition-all cursor-pointer">
                  Ver cómo funciona
                </button>
              </div>
              <p class="mt-4 text-sm text-slate-500 flex items-center gap-1">
                <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                No requiere tarjeta de crédito para iniciar
              </p>
            </div>

            <div class="relative lg:ml-auto transition-all duration-700 delay-150 ${animado ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'}">
              <div class="absolute inset-0 bg-brand-200 rounded-[2.5rem] transform rotate-3 scale-105 opacity-50 blur-lg"></div>
              <img src="https://placehold.co/800x600/0f766e/ffffff?text=Padre+e+Hijo+Haciendo+Tarea+Felices"
                   alt="Padre e hijo estudiando juntos"
                   class="relative rounded-[2rem] shadow-2xl w-full object-cover border-4 border-white" />

              <div class="absolute -bottom-6 -left-6 bg-white p-4 rounded-2xl shadow-xl flex items-center gap-4 animate-bounce" style="animation-duration: 3s;">
                <div class="bg-yellow-100 p-2 rounded-full">
                  <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                  </svg>
                </div>
                <div>
                  <p class="text-sm font-bold text-slate-900">¡Lo entendió!</p>
                  <p class="text-xs text-slate-500">Fracciones dominadas</p>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>
    `;
  }
}
