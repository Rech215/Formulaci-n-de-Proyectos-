import { ViewComponent } from './ViewComponent';
import { Router } from '../router/Router';

interface HowItWorksState {
  pasoActivo: number;
  animado: boolean;
}

interface PasoProceso {
  numero: number;
  titulo: string;
  descripcion: string;
  icono: string;
  destacado: boolean;
}

interface AlineacionSEP {
  materia: string;
  tema: string;
  metodoEscolar: string;
  preguntasGuia: string[];
  reglaClave: string;
}

export class HowItWorksView extends ViewComponent<HowItWorksState> {
  private readonly pasos: PasoProceso[] = [
    {
      numero: 1,
      titulo: 'Toma una foto',
      descripcion: 'Captura el problema, la instrucción del cuaderno o la página del libro de texto.',
      icono: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>',
      destacado: false,
    },
    {
      numero: 2,
      titulo: 'Entiende el método actual',
      descripcion: 'La IA te explica cómo se enseña ese tema hoy en la escuela y lo alinea con el método SEP.',
      icono: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>',
      destacado: false,
    },
    {
      numero: 3,
      titulo: 'Recibe preguntas guía',
      descripcion: 'Obtienes 2 o 3 preguntas sencillas y estrategias didácticas para acompañar a tu hijo.',
      icono: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>',
      destacado: false,
    },
    {
      numero: 4,
      titulo: 'Él lo descubre',
      descripcion: 'Acompañas sin dar la respuesta final. Tu hijo llega al resultado y gana confianza.',
      icono: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"></path>',
      destacado: true,
    },
  ];

  private readonly alineacionDemo: AlineacionSEP;

  constructor() {
    super('Cómo funciona', '/como-funciona', { pasoActivo: 0, animado: false });
    this.alineacionDemo = this.alinearMetodoSEP('Fracciones equivalentes');
  }

  protected onMount(): void {
    setTimeout(() => this.actualizarEstado({ animado: true }), 100);

    this.registrarEventoMultiple('.paso-item', 'click', (_e: Event, indice: number) => {
      this.actualizarEstado({ pasoActivo: indice });
    });

    this.registrarEvento('#ver-planes', 'click', (e: Event) => {
      e.preventDefault();
      Router.obtenerInstancia().navegarA('/planes');
    });
  }

  protected render(): string {
    const { pasoActivo, animado } = this.estado;
    const paso = this.pasos[pasoActivo];

    return `
      <section class="py-24 bg-slate-900 text-white min-h-screen">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

          <div class="text-center max-w-3xl mx-auto mb-16">
            <span class="text-brand-400 font-semibold tracking-wider uppercase text-sm">Proceso Simple</span>
            <h2 class="text-3xl md:text-4xl font-bold mt-2 mb-4">Empodérate en 4 sencillos pasos</h2>
            <p class="text-slate-400 text-lg">
              Nuestra IA hace el trabajo pesado de analizar el método, tú te encargas de ser el mejor guía.
            </p>
          </div>

          <div class="grid md:grid-cols-4 gap-8 relative">
            <div class="hidden md:block absolute top-12 left-[12.5%] right-[12.5%] h-0.5 bg-slate-800"></div>
            ${this.pasos.map((item, indice) => this.renderPaso(item, indice, pasoActivo, animado)).join('')}
          </div>

          <div class="mt-16 max-w-2xl mx-auto">
            <div class="bg-slate-800 rounded-2xl p-8 border border-slate-700 transition-all duration-300">
              <div class="flex items-center gap-4 mb-4">
                <span class="bg-brand-500 text-white w-10 h-10 rounded-full flex items-center justify-center font-bold text-lg">
                  ${paso.numero}
                </span>
                <h3 class="text-2xl font-bold">${paso.titulo}</h3>
              </div>
              <p class="text-slate-300 text-lg leading-relaxed">
                ${paso.descripcion}
              </p>
            </div>
          </div>

          ${this.renderAlineacionSEP()}

          <div class="text-center mt-12">
            <button id="ver-planes"
              class="bg-brand-500 hover:bg-brand-400 text-white px-8 py-4 rounded-full font-semibold text-lg transition-all shadow-lg hover:shadow-xl cursor-pointer">
              Ver planes y precios →
            </button>
          </div>

        </div>
      </section>
    `;
  }

  private alinearMetodoSEP(tema: string): AlineacionSEP {
    return {
      materia: 'Matemáticas',
      tema,
      metodoEscolar: 'La SEP introduce el tema con material concreto, representaciones gráficas y la recta numérica antes de llegar a la regla numérica.',
      preguntasGuia: this.generarPreguntasGuia(tema),
      reglaClave: this.acompanarSinRespuestaFinal('El niño ya intentó resolverlo por su cuenta.'),
    };
  }

  private generarPreguntasGuia(tema: string): string[] {
    return [
      `¿Qué representa cada parte de la tarea de ${tema.toLowerCase()}?`,
      '¿Puedes dibujarlo o usar un objeto de casa para explicarlo?',
      '¿Qué pasaría si cambias el orden o el tamaño de las partes?',
    ];
  }

  private acompanarSinRespuestaFinal(intento: string): string {
    if (!intento.trim()) {
      return 'Pregúntale primero qué parte del problema ya entiende y qué parte le genera duda.';
    }
    return 'Valida su intento y devuélvele una pregunta: "¿Cómo podrías comprobarlo?". Nunca le des el resultado final.';
  }

  private renderPaso(
    paso: PasoProceso,
    indice: number,
    activo: number,
    animado: boolean,
  ): string {
    const esActivo = indice === activo;
    const delay = indice * 100;
    const circuloBg = paso.destacado
      ? 'bg-brand-600'
      : esActivo
        ? 'bg-brand-500'
        : 'bg-slate-800';
    const ringColor = esActivo ? 'ring-4 ring-brand-500/40' : '';
    const tituloColor = paso.destacado
      ? 'text-brand-300'
      : esActivo
        ? 'text-white'
        : 'text-slate-300';

    return `
      <div class="paso-item relative text-center cursor-pointer group transition-all duration-500"
           style="transition-delay: ${delay}ms; opacity: ${animado ? 1 : 0}; transform: translateY(${animado ? 0 : 20}px);">
        <div class="w-24 h-24 mx-auto ${circuloBg} ${ringColor} border-4 border-slate-900 rounded-full flex items-center justify-center mb-6 shadow-xl relative z-10 transition-all duration-300 group-hover:scale-110">
          <span class="absolute -top-2 -right-2 ${paso.destacado ? 'bg-white text-brand-600' : 'bg-brand-500 text-white'} w-8 h-8 rounded-full flex items-center justify-center font-bold shadow">
            ${paso.numero}
          </span>
          <svg class="w-10 h-10 ${paso.destacado ? 'text-white' : 'text-brand-400'}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            ${paso.icono}
          </svg>
        </div>
        <h3 class="text-xl font-bold mb-2 ${tituloColor} transition-colors">${paso.titulo}</h3>
        <p class="text-slate-400 text-sm">${paso.descripcion}</p>
      </div>
    `;
  }

  private renderAlineacionSEP(): string {
    return `
      <div class="mt-16 bg-brand-900/60 border border-brand-700 rounded-3xl p-8 max-w-4xl mx-auto">
        <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-6 mb-6">
          <div>
            <span class="text-brand-300 font-semibold tracking-wider uppercase text-sm">Diferenciador curricular</span>
            <h3 class="text-2xl font-bold mt-1">Alineación simulada al método SEP</h3>
          </div>
          <span class="inline-flex items-center gap-2 bg-brand-500/20 text-brand-200 px-4 py-2 rounded-full text-sm font-semibold">
            <span class="w-2 h-2 rounded-full bg-brand-400 animate-pulse"></span>
            ${this.alineacionDemo.materia} · ${this.alineacionDemo.tema}
          </span>
        </div>

        <div class="grid md:grid-cols-2 gap-6">
          <div class="bg-slate-900/70 rounded-2xl p-6 border border-slate-700">
            <h4 class="font-bold text-white mb-3">Método escolar detectado</h4>
            <p class="text-slate-300 leading-relaxed">${this.alineacionDemo.metodoEscolar}</p>
          </div>
          <div class="bg-slate-900/70 rounded-2xl p-6 border border-slate-700">
            <h4 class="font-bold text-white mb-3">Preguntas guía generadas</h4>
            <ul class="space-y-3">
              ${this.alineacionDemo.preguntasGuia.map((pregunta) => `
                <li class="flex items-start gap-3 text-slate-300">
                  <span class="text-brand-400 font-bold">?</span>
                  <span>${pregunta}</span>
                </li>
              `).join('')}
            </ul>
          </div>
        </div>

        <div class="mt-6 flex items-start gap-3 bg-brand-500/10 border border-brand-500/30 rounded-2xl p-4">
          <svg class="w-5 h-5 text-brand-300 mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
          </svg>
          <p class="text-brand-100 text-sm leading-relaxed">${this.alineacionDemo.reglaClave}</p>
        </div>
      </div>
    `;
  }
}
