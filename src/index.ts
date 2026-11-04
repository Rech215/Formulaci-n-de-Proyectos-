export {
  IPadre,
  IHijo,
  PadreDTO,
  ITarea,
  EstadoTarea,
  ResultadoAnalisis,
  TareaDTO,
  ISuscripcion,
  TipoPlan,
  EstadoSuscripcion,
  SuscripcionDTO,
} from './interfaces/index';

export { Padre } from './models/Padre';
export { Tarea } from './models/Tarea';
export { Suscripcion } from './models/Suscripcion';
export { Plan } from './models/Plan';
export type { PlanConfig } from './models/Plan';

export { EduGuiaService } from './services/EduGuiaService';
export type { ResumenUso } from './services/EduGuiaService';

export { Router } from './router/Router';
export type { RutaDefinida, ListenerNavegacion } from './router/Router';

export { ViewComponent } from './views/ViewComponent';
export type { ViewState, MountableView } from './views/ViewComponent';
export { HomeView } from './views/HomeView';
export { ProblemView } from './views/ProblemView';
export { HowItWorksView } from './views/HowItWorksView';
export { PricingView } from './views/PricingView';
export { NavbarComponent } from './views/NavbarComponent';
export { FooterComponent } from './views/FooterComponent';
