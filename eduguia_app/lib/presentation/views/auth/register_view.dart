import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/hijo.dart';
import '../../state/session_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/error_feedback.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _hijoNombre = TextEditingController();
  final _hijoEdad = TextEditingController();
  final _hijoGrado = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _hijoNombre.dispose();
    _hijoEdad.dispose();
    _hijoGrado.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>();
    await session.registrar(
      nombre: _nombre.text.trim(),
      correo: _correo.text.trim(),
      password: _password.text,
      hijos: <Hijo>[
        Hijo(
          nombre: _hijoNombre.text.trim(),
          edad: int.parse(_hijoEdad.text.trim()),
          gradoEscolar: _hijoGrado.text.trim(),
        ),
      ],
    );

    if (!mounted) return;
    if (session.haySesion) {
      context.go('/inicio');
    } else {
      ErrorFeedback.show(context, session.errorExcepcion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brand700,
        foregroundColor: Colors.white,
        title: const BrandLogo(compact: true, dark: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Necesitamos un hijo para personalizar el análisis de '
                      'sus tareas.',
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'TUS DATOS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nombre,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tu nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (valor) => (valor?.trim().isEmpty ?? true)
                          ? 'Escribe tu nombre.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _correo,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (valor) {
                        final correo = valor?.trim() ?? '';
                        if (correo.isEmpty || !correo.contains('@')) {
                          return 'Escribe un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _ocultar,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _ocultar
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                          icon: Icon(
                            _ocultar
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (valor) => (valor ?? '').length < 6
                          ? 'Usa al menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'TU HIJO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _hijoNombre,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del hijo',
                        prefixIcon: Icon(Icons.child_care_outlined),
                      ),
                      validator: (valor) => (valor?.trim().isEmpty ?? true)
                          ? 'Escribe el nombre de tu hijo.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _hijoEdad,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Edad',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            validator: (valor) {
                              final edad = int.tryParse(valor?.trim() ?? '');
                              if (edad == null || edad < 3 || edad > 18) {
                                return 'De 3 a 18 años.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _hijoGrado,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _registrar(),
                            decoration: const InputDecoration(
                              labelText: 'Grado escolar',
                              hintText: '4to Primaria',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                            validator: (valor) =>
                                (valor?.trim().isEmpty ?? true)
                                    ? 'Indica el grado.'
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (session.error != null) ...<Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.red100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session.error!,
                          style: const TextStyle(
                            color: AppColors.red600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    FilledButton(
                      onPressed: session.cargando ? null : _registrar,
                      child: session.cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crear cuenta'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed:
                          session.cargando ? null : () => context.go('/login'),
                      child: const Text('Ya tengo una cuenta'),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Al crear una cuenta aceptas los términos de servicio y '
                      'el aviso de privacidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.slate500,
                        height: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => context.push('/legal/terminos'),
                          child: const Text(
                            'Términos',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const Text(
                          '·',
                          style: TextStyle(color: AppColors.slate400),
                        ),
                        TextButton(
                          onPressed: () => context.push('/legal/privacidad'),
                          child: const Text(
                            'Privacidad',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
