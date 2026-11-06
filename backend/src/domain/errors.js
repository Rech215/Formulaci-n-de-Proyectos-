export class AppError extends Error {
  constructor(message, { status = 400, code = 'SOLICITUD_INVALIDA', details } = {}) {
    super(message);
    this.name = 'AppError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export class NoAutorizadoError extends AppError {
  constructor(message = 'No autorizado.') {
    super(message, { status: 401, code: 'NO_AUTORIZADO' });
  }
}

export class NoEncontradoError extends AppError {
  constructor(message = 'Recurso no encontrado.') {
    super(message, { status: 404, code: 'NO_ENCONTRADO' });
  }
}

export class LimitePlanError extends AppError {
  constructor(message) {
    super(message, { status: 402, code: 'LIMITE_PLAN' });
  }
}
