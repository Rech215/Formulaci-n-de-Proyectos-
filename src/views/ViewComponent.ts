export type ViewState = Record<string, unknown>;

export interface MountableView {
  readonly estaMontado: boolean;
  montar(contenedor: HTMLElement): void;
  desmontar(): void;
}

export abstract class ViewComponent<T extends object = ViewState> implements MountableView {
  private _estado: T;
  private _montado: boolean;
  private _contenedor: HTMLElement | null;
  private _eventListeners: Array<{
    elemento: EventTarget;
    evento: string;
    handler: EventListenerOrEventListenerObject;
  }>;

  protected readonly titulo: string;
  protected readonly ruta: string;

  constructor(titulo: string, ruta: string, estadoInicial: T) {
    this.titulo = titulo;
    this.ruta = ruta;
    this._estado = { ...estadoInicial } as T;
    this._montado = false;
    this._contenedor = null;
    this._eventListeners = [];
  }

  get estado(): Readonly<T> {
    return { ...this._estado };
  }

  get estaMontado(): boolean {
    return this._montado;
  }

  get contenedor(): HTMLElement | null {
    return this._contenedor;
  }

  protected actualizarEstado(parcial: Partial<T>): void {
    const claves = Object.keys(parcial) as Array<keyof T>;
    const cambio = claves.some((clave) => this._estado[clave] !== parcial[clave]);

    if (!cambio) return;

    this._estado = { ...this._estado, ...parcial } as T;
    if (this._montado && this._contenedor) {
      this.reRenderizar();
    }
  }

  protected obtenerEstado<K extends keyof T>(clave: K): T[K] {
    return this._estado[clave];
  }

  montar(contenedor: HTMLElement): void {
    if (this._montado) {
      this.desmontar();
    }

    this._contenedor = contenedor;
    this.onInit();
    this._contenedor.innerHTML = this.render();
    this._montado = true;
    this.onMount();
    document.title = `EduGuía — ${this.titulo}`;
  }

  desmontar(): void {
    if (!this._montado) return;

    this.onDestroy();
    this.limpiarEventListeners();

    if (this._contenedor) {
      this._contenedor.innerHTML = '';
    }

    this._montado = false;
    this._contenedor = null;
  }

  protected abstract render(): string;

  protected onInit(): void {}

  protected onMount(): void {}

  protected onDestroy(): void {}

  protected registrarEvento(
    selector: string,
    evento: string,
    handler: EventListenerOrEventListenerObject,
  ): void {
    if (!this._contenedor) return;

    const elemento = this._contenedor.querySelector(selector);
    if (!elemento) return;

    elemento.addEventListener(evento, handler);
    this._eventListeners.push({ elemento, evento, handler });
  }

  protected registrarEventoMultiple(
    selector: string,
    evento: string,
    handler: (e: Event, indice: number) => void,
  ): void {
    if (!this._contenedor) return;

    const elementos = this._contenedor.querySelectorAll(selector);
    elementos.forEach((elemento, indice) => {
      const wrappedHandler = (e: Event) => handler(e, indice);
      elemento.addEventListener(evento, wrappedHandler);
      this._eventListeners.push({ elemento, evento, handler: wrappedHandler });
    });
  }

  protected querySelector<E extends Element = Element>(selector: string): E | null {
    return this._contenedor?.querySelector<E>(selector) ?? null;
  }

  protected querySelectorAll<E extends Element = Element>(selector: string): NodeListOf<E> {
    if (this._contenedor) {
      return this._contenedor.querySelectorAll<E>(selector);
    }
    return document.createDocumentFragment().querySelectorAll<E>(selector);
  }

  private reRenderizar(): void {
    if (!this._contenedor) return;

    const scrollTop = this._contenedor.scrollTop;
    this.limpiarEventListeners();
    this.onDestroy();
    this._contenedor.innerHTML = this.render();
    this.onMount();
    this._contenedor.scrollTop = scrollTop;
  }

  private limpiarEventListeners(): void {
    for (const { elemento, evento, handler } of this._eventListeners) {
      elemento.removeEventListener(evento, handler);
    }
    this._eventListeners = [];
  }
}
