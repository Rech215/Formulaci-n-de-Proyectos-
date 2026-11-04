import type { MountableView } from '../views/ViewComponent';

export interface RutaDefinida {
  ruta: string;
  vista: MountableView;
  etiqueta: string;
}

export type ListenerNavegacion = (rutaAnterior: string, rutaNueva: string) => void;

export class Router {
  private static _instancia: Router | null = null;

  static obtenerInstancia(): Router {
    if (!Router._instancia) {
      Router._instancia = new Router();
    }
    return Router._instancia;
  }

  private _rutas: Map<string, RutaDefinida>;
  private _rutaActual: string;
  private _rutaPorDefecto: string;
  private _contenedor: HTMLElement | null;
  private _vistaActual: MountableView | null;
  private _listeners: ListenerNavegacion[];
  private _hashChangeHandler: (() => void) | null;
  private _inicializado: boolean;

  private constructor() {
    this._rutas = new Map();
    this._rutaActual = '';
    this._rutaPorDefecto = '/inicio';
    this._contenedor = null;
    this._vistaActual = null;
    this._listeners = [];
    this._hashChangeHandler = null;
    this._inicializado = false;
  }

  get rutaActual(): string {
    return this._rutaActual;
  }

  get rutasRegistradas(): RutaDefinida[] {
    return Array.from(this._rutas.values());
  }

  get vistaActual(): MountableView | null {
    return this._vistaActual;
  }

  get inicializado(): boolean {
    return this._inicializado;
  }

  registrarRuta(ruta: string, vista: MountableView, etiqueta: string): Router {
    this._rutas.set(ruta, { ruta, vista, etiqueta });
    return this;
  }

  establecerRutaPorDefecto(ruta: string): Router {
    this._rutaPorDefecto = ruta;
    return this;
  }

  alNavegar(listener: ListenerNavegacion): Router {
    this._listeners.push(listener);
    return this;
  }

  inicializar(contenedorId: string): void {
    const contenedor = document.getElementById(contenedorId);
    if (!contenedor) {
      throw new Error(`Router: No se encontró el contenedor DOM con id "${contenedorId}".`);
    }

    this._contenedor = contenedor;
    this._hashChangeHandler = () => this.manejarCambioRuta();
    window.addEventListener('hashchange', this._hashChangeHandler);
    this._inicializado = true;
    this.manejarCambioRuta();
  }

  destruir(): void {
    if (this._hashChangeHandler) {
      window.removeEventListener('hashchange', this._hashChangeHandler);
      this._hashChangeHandler = null;
    }

    if (this._vistaActual) {
      this._vistaActual.desmontar();
      this._vistaActual = null;
    }

    this._inicializado = false;
    Router._instancia = null;
  }

  navegarA(ruta: string): void {
    window.location.hash = `#${ruta}`;
  }

  esRutaActiva(ruta: string): boolean {
    return this._rutaActual === ruta;
  }

  private manejarCambioRuta(): void {
    const hash = window.location.hash.slice(1) || this._rutaPorDefecto;
    const rutaLimpia = this.normalizarRuta(hash);

    if (rutaLimpia === this._rutaActual && this._vistaActual?.estaMontado) {
      return;
    }

    const rutaDefinida = this._rutas.get(rutaLimpia);

    if (!rutaDefinida) {
      console.warn(`Router: Ruta "${rutaLimpia}" no registrada. Redirigiendo a "${this._rutaPorDefecto}".`);
      this.navegarA(this._rutaPorDefecto);
      return;
    }

    this.ejecutarTransicion(rutaLimpia, rutaDefinida.vista);
  }

  private ejecutarTransicion(nuevaRuta: string, nuevaVista: MountableView): void {
    if (!this._contenedor) return;

    const rutaAnterior = this._rutaActual;

    if (this._vistaActual) {
      this._contenedor.classList.add('opacity-0');

      setTimeout(() => {
        this._vistaActual?.desmontar();
        this._rutaActual = nuevaRuta;
        this._vistaActual = nuevaVista;
        nuevaVista.montar(this._contenedor!);

        requestAnimationFrame(() => {
          this._contenedor!.classList.remove('opacity-0');
        });

        this.notificarListeners(rutaAnterior, nuevaRuta);
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }, 200);
    } else {
      this._rutaActual = nuevaRuta;
      this._vistaActual = nuevaVista;
      nuevaVista.montar(this._contenedor);
      this.notificarListeners(rutaAnterior, nuevaRuta);
    }
  }

  private notificarListeners(anterior: string, nueva: string): void {
    for (const listener of this._listeners) {
      try {
        listener(anterior, nueva);
      } catch (error) {
        console.error('Router: Error en listener de navegación:', error);
      }
    }
  }

  private normalizarRuta(ruta: string): string {
    let normalizada = ruta.trim().toLowerCase();
    if (!normalizada.startsWith('/')) {
      normalizada = '/' + normalizada;
    }
    if (normalizada.length > 1 && normalizada.endsWith('/')) {
      normalizada = normalizada.slice(0, -1);
    }
    return normalizada;
  }
}
