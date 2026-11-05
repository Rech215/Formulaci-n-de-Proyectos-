import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/section_header.dart';

class HowItWorksView extends StatefulWidget {
  const HowItWorksView({super.key});

  @override
  State<HowItWorksView> createState() => _HowItWorksViewState();
}

class _HowItWorksViewState extends State<HowItWorksView> {
  static const List<_PasoProceso> _pasos = <_PasoProceso>[
    _PasoProceso(
      numero: 1,
      titulo: 'Toma una foto',
      descripcion:
          'Captura el problema, la instrucción del cuaderno o la página del libro de texto.',
      icono: Icons.photo_camera_outlined,
      destacado: false,
    ),
    _PasoProceso(
      numero: 2,
      titulo: 'Entiende el método actual',
      descripcion:
          'La IA te explica cómo se enseña ese tema hoy en la escuela y lo alinea con el método SEP.',
      icono: Icons.lightbulb_outline,
      destacado: false,
    ),
    _PasoProceso(
      numero: 3,
      titulo: 'Recibe preguntas guía',
      descripcion:
          'Obtienes 2 o 3 preguntas sencillas y estrategias didácticas para acompañar a tu hijo.',
      icono: Icons.chat_bubble_outline,
      destacado: false,
    ),
    _PasoProceso(
      numero: 4,
      titulo: 'Él lo descubre',
      descripcion:
          'Acompañas sin dar la respuesta final. Tu hijo llega al resultado y gana confianza.',
      icono: Icons.auto_awesome,
      destacado: true,
    ),
  ];

  static const _AlineacionSEP _alineacion = _AlineacionSEP(
    materia: 'Matemáticas',
    tema: 'Fracciones equivalentes',
    metodoEscolar:
        'La SEP introduce el tema con material concreto, representaciones '
        'gráficas y la recta numérica antes de llegar a la regla numérica.',
    preguntasGuia: <String>[
      '¿Qué representa cada parte de la tarea de fracciones equivalentes?',
      '¿Puedes dibujarlo o usar un objeto de casa para explicarlo?',
      '¿Qué pasaría si cambias el orden o el tamaño de las partes?',
    ],
    reglaClave:
        'Valida su intento y devuélvele una pregunta: "¿Cómo podrías comprobarlo?". '
        'Nunca le des el resultado final.',
  );

  int _pasoActivo = 0;

  @override
  Widget build(BuildContext context) {
    final paso = _pasos[_pasoActivo];

    return Container(
      width: double.infinity,
      color: AppColors.slate900,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: <Widget>[
                const SectionHeader(
                  eyebrow: 'Proceso Simple',
                  eyebrowColor: AppColors.brand400,
                  title: 'Empodérate en 4 sencillos pasos',
                  subtitle:
                      'Nuestra IA hace el trabajo pesado de analizar el método, '
                      'tú te encargas de ser el mejor guía.',
                  dark: true,
                ),
                const SizedBox(height: 32),
                _buildPasos(),
                const SizedBox(height: 24),
                _DetallePaso(paso: paso),
                const SizedBox(height: 24),
                const _AlineacionCard(alineacion: _alineacion),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.go('/planes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Ver planes y precios',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;
        final items = <Widget>[
          for (var i = 0; i < _pasos.length; i++)
            _PasoCard(
              paso: _pasos[i],
              activo: i == _pasoActivo,
              onTap: () => setState(() => _pasoActivo = i),
              width: isWide ? null : 180,
            ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < items.length; i++) ...<Widget>[
                Expanded(child: items[i]),
                if (i != items.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < items.length; i++) ...<Widget>[
                items[i],
                if (i != items.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PasoCard extends StatelessWidget {
  const _PasoCard({
    required this.paso,
    required this.activo,
    required this.onTap,
    this.width,
  });

  final _PasoProceso paso;
  final bool activo;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final circuloColor = paso.destacado
        ? AppColors.brand600
        : activo
            ? AppColors.brand500
            : AppColors.slate800;
    final tituloColor = paso.destacado
        ? AppColors.brand300
        : activo
            ? Colors.white
            : AppColors.slate300;

    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: circuloColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activo ? AppColors.brand400 : AppColors.slate900,
                      width: 4,
                    ),
                    boxShadow: activo
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AppColors.brand500.withAlpha(77),
                              blurRadius: 20,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: Icon(
                    paso.icono,
                    size: 36,
                    color: paso.destacado ? Colors.white : AppColors.brand300,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: paso.destacado ? Colors.white : AppColors.brand500,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${paso.numero}',
                      style: TextStyle(
                        color: paso.destacado
                            ? AppColors.brand600
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              paso.titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: tituloColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              paso.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );

    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}

class _DetallePaso extends StatelessWidget {
  const _DetallePaso({required this.paso});

  final _PasoProceso paso;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 720),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brand500,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${paso.numero}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  paso.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            paso.descripcion,
            style: const TextStyle(
              color: AppColors.slate300,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlineacionCard extends StatelessWidget {
  const _AlineacionCard({required this.alineacion});

  final _AlineacionSEP alineacion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.brand900.withAlpha(204),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.brand700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'DIFERENCIADOR CURRICULAR',
            style: TextStyle(
              color: AppColors.brand300,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Alineación simulada al método SEP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brand500.withAlpha(51),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${alineacion.materia} · ${alineacion.tema}',
              style: const TextStyle(
                color: AppColors.brand200,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final metodo = _AlineacionBloque(
                titulo: 'Método escolar detectado',
                child: Text(
                  alineacion.metodoEscolar,
                  style: const TextStyle(
                    color: AppColors.slate300,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              );
              final preguntas = _AlineacionBloque(
                titulo: 'Preguntas guía generadas',
                child: Column(
                  children: <Widget>[
                    for (final pregunta in alineacion.preguntasGuia)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              '?',
                              style: TextStyle(
                                color: AppColors.brand400,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pregunta,
                                style: const TextStyle(
                                  color: AppColors.slate300,
                                  height: 1.4,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: metodo),
                    const SizedBox(width: 16),
                    Expanded(child: preguntas),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  metodo,
                  const SizedBox(height: 16),
                  preguntas,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brand500.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brand500.withAlpha(77)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.brand300,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alineacion.reglaClave,
                    style: const TextStyle(
                      color: AppColors.brand100,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlineacionBloque extends StatelessWidget {
  const _AlineacionBloque({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.slate900.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PasoProceso {
  const _PasoProceso({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.destacado,
  });

  final int numero;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final bool destacado;
}

class _AlineacionSEP {
  const _AlineacionSEP({
    required this.materia,
    required this.tema,
    required this.metodoEscolar,
    required this.preguntasGuia,
    required this.reglaClave,
  });

  final String materia;
  final String tema;
  final String metodoEscolar;
  final List<String> preguntasGuia;
  final String reglaClave;
}
