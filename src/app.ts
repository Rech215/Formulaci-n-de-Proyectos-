import { Plan } from './models/Plan';
import { Router } from './router/Router';
import { FooterComponent } from './views/FooterComponent';
import { HomeView } from './views/HomeView';
import { HowItWorksView } from './views/HowItWorksView';
import { NavbarComponent } from './views/NavbarComponent';
import { PricingView } from './views/PricingView';
import { ProblemView } from './views/ProblemView';

const router = Router.obtenerInstancia();

router
  .registrarRuta('/inicio', new HomeView(), 'Inicio')
  .registrarRuta('/problema', new ProblemView(), 'El Problema')
  .registrarRuta('/como-funciona', new HowItWorksView(), 'Cómo funciona')
  .registrarRuta('/planes', new PricingView([Plan.gratuito(), Plan.premium()]), 'Planes')
  .establecerRutaPorDefecto('/inicio');

const navbar = new NavbarComponent();
navbar.montar('navbar');

const footer = new FooterComponent();
footer.montar('footer');

router.inicializar('app');
