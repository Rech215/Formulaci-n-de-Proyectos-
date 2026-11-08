import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/onboarding_provider.dart';
import '../widgets/brand_logo.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _pagina = 0;

  static const List<_PaginaOnboarding> _paginas = <_PaginaOnboarding>[
    _PaginaOnboarding(
      icono: Icons.document_scanner_outlined,
      titulo: 'Escanea la tarea',
      texto: 'Toma una foto clara de la tarea de tu hijo. La app identifica '
          'la materia, el tema y el método que usa su escuela.',
      color: AppColors.brand600,
    ),
    _PaginaOnboarding(
      icono: Icons.school_outlined,
      titulo: 'Entiende el método SEP',
      texto: 'Recibe una explicación sencilla del enfoque escolar para que '
          'puedas acompañar sin confundir a tu hijo con otros métodos.',
      color: AppColors.green600,
    ),
    _PaginaOnboarding(
      icono: Icons.chat_bubble_outline,
      titulo: 'Acompaña, no resuelvas',
      texto: 'Usa las preguntas guía para que tu hijo descubra la respuesta '
          'por sí mismo. Guarda cada tarea para repasarla cuando quieras.',
      color: AppColors.yellow600,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _siguiente() async {
    if (_pagina == _paginas.length - 1) {
      await context.read<OnboardingProvider>().completar();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esUltima = _pagina == _paginas.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                children: <Widget>[
                  const BrandLogo(compact: true),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        context.read<OnboardingProvider>().completar(),
                    child: const Text('Saltar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _paginas.length,
                onPageChanged: (indice) => setState(() => _pagina = indice),
                itemBuilder: (context, indice) {
                  final pagina = _paginas[indice];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: pagina.color.withAlpha(28),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    pagina.color,
                                    pagina.color.withAlpha(190),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: pagina.color.withAlpha(64),
                                    blurRadius: 26,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Icon(
                                pagina.icono,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          pagina.titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          pagina.texto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.slate500,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (var i = 0; i < _paginas.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _pagina ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _pagina
                                ? AppColors.brand600
                                : AppColors.slate300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _siguiente,
                      child: Text(esUltima ? 'Comenzar' : 'Siguiente'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginaOnboarding {
  const _PaginaOnboarding({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.color,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final Color color;
}
