# EduGuía (Flutter)

Migración móvil nativa del proyecto web EduGuía a Flutter con **Clean Architecture**.

## Arquitectura

```
lib/
  domain/          # Entidades inmutables + contratos + casos de uso
  data/            # Repositorios remotos/mock + servicios locales (prefs, cámara)
  presentation/    # UI Material + SessionProvider/AnalysisProvider (Provider)
  core/            # Tema teal/slate, go_router, errores
```

| Capa | Contenido |
|------|-----------|
| Dominio | `Padre`, `Tarea`, `Suscripcion`, `Plan`, `Hijo` con validación en factories |
| Casos de uso | Orquestación equivalente a `EduGuiaService.ts` |
| Estado | `SessionProvider` + `AnalysisProvider`; `get_it` inyecta repositorios |
| UI | `HomeView`, `ProblemView`, `HowItWorksView`, `PricingView`, `ScanView`, `HistorialView` |
| Navegación | `go_router` → `/inicio`, `/problema`, `/como-funciona`, `/planes`, `/escanear`, `/historial` |

## Experiencia móvil

- **Recorte de tareas**: tras tomar una foto o elegir de la galería se abre
  `image_cropper` con la identidad Slate/Teal.
- **Límite gratuito local**: `shared_preferences` guarda 5 consultas por padre.
  Cada análisis exitoso descuenta una; al llegar a 0 se bloquea la cámara y se
  redirige a `/planes`. Los usuarios Premium no consumen el contador.
- **Historial local**: las tareas analizadas se guardan como JSON en el
  dispositivo (máximo 100) para repasar el método SEP y las preguntas guía.
- **Marca nativa**: icono adaptativo y splash generados con
  `flutter_launcher_icons` y `flutter_native_splash` desde `assets/branding/`.
  Regenerar con `tool/generate_branding_assets.ps1`.

## Ejecutar

```bash
# Si Flutter no está en PATH (instalación local de esta máquina):
#   %USERPROFILE%\develop\flutter\bin\flutter.bat

flutter pub get
flutter test
flutter run
```

Paleta: turquesa/teal (`brand*`) + slate, igual que el sitio web.
