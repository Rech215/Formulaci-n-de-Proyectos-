import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../state/session_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/error_feedback.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>();
    await session.iniciarSesion(
      correo: _correo.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;
    if (session.haySesion) {
      context.go('/home');
    } else {
      ErrorFeedback.show(context, session.errorExcepcion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[AppColors.brand700, AppColors.brand500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const BrandLogo(dark: true),
                    const SizedBox(height: 28),
                    const Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acompaña el aprendizaje de tu hijo sin hacerle la tarea.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            controller: _correo,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const <String>[AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'tu@correo.com',
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
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _ocultar,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _entrar(),
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _ocultar
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: () =>
                                    setState(() => _ocultar = !_ocultar),
                                icon: Icon(
                                  _ocultar
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (valor) {
                              if ((valor ?? '').length < 6) {
                                return 'Usa al menos 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
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
                            onPressed: session.cargando ? null : _entrar,
                            child: session.cargando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Iniciar sesión'),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: session.cargando
                                ? null
                                : () => context.go('/register'),
                            child: const Text('Crear una cuenta nueva'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Al continuar aceptas los términos de servicio y '
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
                                onPressed: () =>
                                    context.push('/legal/terminos'),
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
                                onPressed: () =>
                                    context.push('/legal/privacidad'),
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
            ],
          ),
        ),
      ),
    );
  }
}
