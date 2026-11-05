# EduGuía (Flutter)

Migración móvil nativa del proyecto web EduGuía a Flutter con **Clean Architecture**.

## Arquitectura

```
lib/
  domain/          # Entidades inmutables + contratos + casos de uso
  data/            # Repositorio en memoria (Facade migrado)
  presentation/    # UI Material + SessionProvider (Provider)
  core/            # Tema teal/slate, go_router, errores
```

| Capa | Contenido |
|------|-----------|
| Dominio | `Padre`, `Tarea`, `Suscripcion`, `Plan`, `Hijo` con validación en factories |
| Casos de uso | Orquestación equivalente a `EduGuiaService.ts` |
| Estado | `SessionProvider` reemplaza la sesión acoplada al Router web |
| UI | `HomeView`, `ProblemView`, `HowItWorksView`, `PricingView` |
| Navegación | `go_router` → `/inicio`, `/problema`, `/como-funciona`, `/planes` |

## Ejecutar

```bash
# Si Flutter no está en PATH (instalación local de esta máquina):
#   %USERPROFILE%\develop\flutter\bin\flutter.bat

flutter pub get
flutter test
flutter run
```

Paleta: turquesa/teal (`brand*`) + slate, igual que el sitio web.
