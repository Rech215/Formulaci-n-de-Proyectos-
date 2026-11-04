export interface PlanConfig {
  id: string;
  nombre: string;
  descripcion: string;
  precioMensual: number;
  limiteConsultas: number;
  beneficios: readonly string[];
  destacado?: boolean;
  etiqueta?: string;
}

export class Plan {
  private readonly _id: string;
  private readonly _nombre: string;
  private readonly _descripcion: string;
  private readonly _precioMensual: number;
  private readonly _limiteConsultas: number;
  private readonly _beneficios: string[];
  private readonly _destacado: boolean;
  private readonly _etiqueta: string | null;

  constructor(config: PlanConfig) {
    if (!config.id.trim()) {
      throw new Error('El plan debe tener un identificador.');
    }
    if (!config.nombre.trim()) {
      throw new Error('El plan debe tener un nombre.');
    }
    if (config.precioMensual < 0) {
      throw new Error('El precio mensual no puede ser negativo.');
    }
    if (config.limiteConsultas === 0) {
      throw new Error('El plan debe permitir al menos una consulta.');
    }

    this._id = config.id.trim();
    this._nombre = config.nombre.trim();
    this._descripcion = config.descripcion.trim();
    this._precioMensual = config.precioMensual;
    this._limiteConsultas = config.limiteConsultas;
    this._beneficios = [...config.beneficios];
    this._destacado = config.destacado ?? false;
    this._etiqueta = config.etiqueta?.trim() || null;
  }

  get id(): string {
    return this._id;
  }

  get nombre(): string {
    return this._nombre;
  }

  get descripcion(): string {
    return this._descripcion;
  }

  get precioMensual(): number {
    return this._precioMensual;
  }

  get limiteConsultas(): number {
    return this._limiteConsultas;
  }

  get beneficios(): readonly string[] {
    return [...this._beneficios];
  }

  get destacado(): boolean {
    return this._destacado;
  }

  get etiqueta(): string | null {
    return this._etiqueta;
  }

  get esGratuito(): boolean {
    return this._precioMensual === 0;
  }

  get esIlimitado(): boolean {
    return this._limiteConsultas < 0;
  }

  get precioFormateado(): string {
    return this.esGratuito ? '$0' : `$${this._precioMensual}`;
  }

  get limiteTexto(): string {
    return this.esIlimitado
      ? 'Consultas ilimitadas'
      : `${this._limiteConsultas} consultas al mes`;
  }

  static gratuito(): Plan {
    return new Plan({
      id: 'gratuito',
      nombre: 'Prueba Gratuita',
      descripcion: 'Para conocer cómo la IA puede ayudarte.',
      precioMensual: 0,
      limiteConsultas: 5,
      beneficios: [
        'Lectura de fotos de tareas',
        'Explicación del método escolar (SEP)',
        '5 consultas al mes',
        'Preguntas guía básicas',
      ],
    });
  }

  static premium(): Plan {
    return new Plan({
      id: 'premium',
      nombre: 'Suscripción Premium',
      descripcion: 'Acompañamiento sin límites para tu hijo.',
      precioMensual: 99,
      limiteConsultas: -1,
      beneficios: [
        'Consultas ilimitadas',
        'Preguntas guía adaptadas a su edad',
        'Alineación curricular SEP',
        'Resumen semanal de logros y áreas de mejora',
        'Ideas de juegos para la vida diaria',
      ],
      destacado: true,
      etiqueta: 'Recomendado',
    });
  }
}
