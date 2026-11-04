import { ViewComponent } from './ViewComponent';
import { Router } from '../router/Router';
import { Plan } from '../models/Plan';

interface PricingState {
  planSeleccionado: string;
  animado: boolean;
  mostrarConfirmacion: boolean;
}

export class PricingView extends ViewComponent<PricingState> {
  private readonly planes: Plan[];

  constructor(planes: Plan[]) {
    if (planes.length < 2) {
      throw new Error('PricingView requiere al menos un plan gratuito y uno de pago.');
    }

    const planInicial = planes.find((plan) => plan.destacado) ?? planes[0];
    super('Precios', '/planes', {
      planSeleccionado: planInicial.id,
      animado: false,
      mostrarConfirmacion: false,
    });

    this.planes = [...planes];
  }

  protected onMount(): void {
    setTimeout(() => this.actualizarEstado({ animado: true }), 100);

    this.registrarEventoMultiple('[data-plan-id]', 'click', (e: Event, indice: number) => {
      e.preventDefault();
      const plan = this.planes[indice];
      if (!plan) return;

      this.actualizarEstado({
        planSeleccionado: plan.id,
        mostrarConfirmacion: true,
      });
    });

    this.registrarEvento('#cerrar-confirmacion', 'click', (e: Event) => {
      e.preventDefault();
      this.actualizarEstado({ mostrarConfirmacion: false });
    });

    this.registrarEvento('#volver-inicio', 'click', (e: Event) => {
      e.preventDefault();
      Router.obtenerInstancia().navegarA('/inicio');
    });
  }

  protected render(): string {
    const { planSeleccionado, animado, mostrarConfirmacion } = this.estado;

    return `
      <section class="py-24 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

          <div class="text-center max-w-3xl mx-auto mb-16">
            <span class="text-brand-600 font-semibold tracking-wider uppercase text-sm">Planes</span>
            <h2 class="text-3xl md:text-4xl font-bold text-slate-900 mb-4 mt-2">
              Invierte en su educación, mejora su relación
            </h2>
            <p class="text-lg text-slate-600">
              Elige el plan que mejor se adapte a las necesidades de tu familia.
            </p>
          </div>

          <div class="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            ${this.planes.map((plan, indice) => this.renderPlanCard(plan, indice, planSeleccionado, animado)).join('')}
          </div>

          ${this.renderCompetitiveAdvantage()}

          ${mostrarConfirmacion ? this.renderModal(planSeleccionado) : ''}

          <div class="text-center mt-12">
            <button id="volver-inicio"
              class="text-slate-500 hover:text-brand-600 font-medium transition-colors cursor-pointer">
              ← Volver al inicio
            </button>
          </div>

        </div>
      </section>
    `;
  }

  private renderPlanCard(plan: Plan, indice: number, seleccionadoId: string, animado: boolean): string {
    const seleccionado = seleccionadoId === plan.id;
    const premium = plan.destacado;
    const delay = indice * 100;

    const cardBase = premium
      ? 'bg-brand-900 text-white border-brand-900 shadow-2xl'
      : 'bg-white text-slate-900 border-slate-100 shadow-sm';

    const cardEstado = premium
      ? seleccionado
        ? 'border-brand-400 ring-4 ring-brand-500/20'
        : 'border-brand-900'
      : seleccionado
        ? 'border-brand-500 shadow-lg'
        : 'border-slate-100 shadow-sm';

    const botonBase = premium
      ? seleccionado
        ? 'bg-white text-brand-700'
        : 'bg-brand-500 hover:bg-brand-400 text-white shadow-lg hover:shadow-xl'
      : seleccionado
        ? 'bg-brand-600 text-white'
        : 'bg-slate-100 hover:bg-slate-200 text-slate-800';

    const tituloColor = premium ? 'text-white' : 'text-slate-900';
    const descripcionColor = premium ? 'text-brand-200' : 'text-slate-500';
    const precioColor = premium ? 'text-white' : 'text-slate-900';
    const periodoColor = premium ? 'text-brand-300' : 'text-slate-500';

    return `
      <div class="${cardBase} ${cardEstado} rounded-3xl p-8 border-2 flex flex-col relative transition-all duration-500 ${premium ? 'md:-translate-y-4' : ''} ${animado ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'}"
           style="transition-delay: ${delay}ms;">
        ${plan.etiqueta ? `
          <div class="absolute top-0 right-8 transform -translate-y-1/2">
            <span class="bg-brand-500 text-white text-xs font-bold uppercase tracking-wider py-1 px-3 rounded-full">
              ${plan.etiqueta}
            </span>
          </div>
        ` : ''}

        <h3 class="text-2xl font-bold ${tituloColor}">${plan.nombre}</h3>
        <p class="${descripcionColor} mt-2">${plan.descripcion}</p>

        <div class="my-6">
          <span class="text-5xl font-extrabold ${precioColor}">${plan.precioFormateado}</span>
          <span class="${periodoColor} font-medium">${plan.esGratuito ? '/mes' : 'MXN /mes'}</span>
        </div>

        <ul class="space-y-4 mb-8 flex-1">
          ${plan.beneficios.map((beneficio) => this.renderBeneficio(beneficio, premium)).join('')}
        </ul>

        <button data-plan-id="${plan.id}"
          class="block w-full py-4 px-6 ${botonBase} font-semibold rounded-xl text-center transition-colors cursor-pointer">
          ${seleccionado ? '✓ Seleccionado' : plan.esGratuito ? 'Comenzar gratis' : 'Suscribirme ahora'}
        </button>
      </div>
    `;
  }

  private renderBeneficio(texto: string, premium: boolean): string {
    const checkColor = premium ? 'text-brand-400' : 'text-brand-500';
    const textColor = premium ? 'text-slate-200' : 'text-slate-600';

    return `
      <li class="flex items-start gap-3">
        <svg class="w-5 h-5 ${checkColor} mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <span class="${textColor}">${texto}</span>
      </li>
    `;
  }

  private renderCompetitiveAdvantage(): string {
    const competidores = [
      {
        nombre: 'Photomath',
        enfoque: 'Le da la respuesta final al instante.',
        resultado: 'Dependencia',
        detalle: 'Resuelve por el niño. No educa al papá ni desarrolla el razonamiento.',
        badgeClass: 'text-red-600 bg-red-100',
      },
      {
        nombre: 'Khanmigo',
        enfoque: 'Conversa directamente con el alumno.',
        resultado: 'Otro usuario',
        detalle: 'Está diseñado para el estudiante, no para que el padre acompañe la tarea.',
        badgeClass: 'text-orange-600 bg-orange-100',
      },
    ];

    return `
      <div class="mt-24 bg-brand-50 rounded-[2rem] p-8 md:p-12 border border-brand-100">
        <div class="max-w-3xl mx-auto text-center mb-12">
          <span class="text-brand-600 font-bold uppercase tracking-wider text-sm">Nuestro diferenciador</span>
          <h3 class="text-3xl md:text-4xl font-extrabold text-slate-900 mt-2 mb-4">
            Hecho para papás, no para reemplazar al maestro.
          </h3>
          <p class="text-lg text-slate-600">
            EduGuía es un producto B2C exclusivo para padres de familia: te enseña el método
            y te da las preguntas correctas para que tú guíes a tu hijo.
          </p>
        </div>

        <div class="grid md:grid-cols-3 gap-6">
          ${competidores.map((item) => `
            <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <h4 class="text-xl font-bold text-slate-900">${item.nombre}</h4>
                <span class="text-xs font-bold uppercase tracking-wider ${item.badgeClass} px-3 py-1 rounded-full">
                  ${item.resultado}
                </span>
              </div>
              <p class="text-slate-700 font-medium mb-2">${item.enfoque}</p>
              <p class="text-slate-500 text-sm leading-relaxed">${item.detalle}</p>
            </div>
          `).join('')}

          <div class="bg-brand-900 rounded-2xl p-6 border-2 border-brand-500 shadow-xl relative transform md:-translate-y-2">
            <div class="absolute top-0 right-6 transform -translate-y-1/2">
              <span class="bg-brand-500 text-white text-xs font-bold uppercase tracking-wider py-1 px-3 rounded-full">
                Nuestra apuesta
              </span>
            </div>
            <div class="flex items-center justify-between mb-4">
              <h4 class="text-xl font-bold text-white">EduGuía</h4>
              <span class="text-xs font-bold uppercase tracking-wider text-brand-900 bg-brand-400 px-3 py-1 rounded-full">
                B2C padres
              </span>
            </div>
            <p class="text-brand-100 font-medium mb-2">Te explica el método SEP y te da preguntas guía.</p>
            <p class="text-brand-200 text-sm leading-relaxed">
              No resuelve la tarea: acompaña al papá para que el niño descubra la respuesta
              y fortalezca su pensamiento crítico.
            </p>
          </div>
        </div>

        <div class="mt-10 grid md:grid-cols-3 gap-4 text-center">
          <div class="bg-white rounded-xl p-4 border border-brand-100">
            <p class="text-2xl font-extrabold text-brand-700">Padres</p>
            <p class="text-sm text-slate-500">Usuario principal del producto</p>
          </div>
          <div class="bg-white rounded-xl p-4 border border-brand-100">
            <p class="text-2xl font-extrabold text-brand-700">SEP</p>
            <p class="text-sm text-slate-500">Parametrización curricular</p>
          </div>
          <div class="bg-white rounded-xl p-4 border border-brand-100">
            <p class="text-2xl font-extrabold text-brand-700">0 respuestas</p>
            <p class="text-sm text-slate-500">Solo preguntas y acompañamiento</p>
          </div>
        </div>
      </div>
    `;
  }

  private renderModal(planId: string): string {
    const plan = this.planes.find((item) => item.id === planId) ?? this.planes[0];
    const esPremium = plan.destacado;

    return `
      <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl transform scale-100 transition-all">
          <div class="text-center">
            <div class="w-16 h-16 mx-auto ${esPremium ? 'bg-brand-100' : 'bg-green-100'} rounded-full flex items-center justify-center mb-4">
              <svg class="w-8 h-8 ${esPremium ? 'text-brand-600' : 'text-green-600'}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
              </svg>
            </div>
            <h3 class="text-2xl font-bold text-slate-900 mb-2">
              ${esPremium ? '¡Excelente elección!' : '¡Bienvenido!'}
            </h3>
            <p class="text-slate-600 mb-6">
              Has seleccionado <strong>${plan.nombre}</strong> (${plan.precioFormateado}${plan.esGratuito ? '' : ' MXN'}/mes).
              ${plan.limiteTexto}.
            </p>
            <button id="cerrar-confirmacion"
              class="w-full py-3 px-6 bg-brand-600 hover:bg-brand-700 text-white font-semibold rounded-xl transition-colors cursor-pointer">
              Entendido
            </button>
          </div>
        </div>
      </div>
    `;
  }
}
