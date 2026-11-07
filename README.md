# EduGuía

Aplicación móvil de acompañamiento escolar para familias. El padre fotografía
una tarea, la IA identifica la materia y el tema, y devuelve un método de
estudio con preguntas guía. Nunca se entrega la respuesta final.

El repositorio contiene:

- `backend/`: API Node.js + Express, MongoDB, JWT, Gemini y RevenueCat.
- `eduguia_app/`: aplicación Flutter con Clean Architecture.
- `backend/openapi.yaml`: contrato HTTP de la API.

## Arquitectura

Backend por capas:

- `src/domain/`: errores y reglas del negocio.
- `src/application/`: servicios, validadores y serializadores.
- `src/infrastructure/`: MongoDB, IA Gemini, JWT y cliente RevenueCat.
- `src/interfaces/http/`: rutas, controladores y middlewares.
- `src/container.js`: composición de dependencias.

Flutter:

- `lib/domain/`: entidades, contratos de repositorio y casos de uso.
- `lib/data/`: repositorios en memoria/API, cliente HTTP y almacenamiento del JWT.
- `lib/presentation/`: providers, vistas y widgets.

## Requisitos

- Node.js 20 o superior.
- MongoDB 6 o superior, local o Atlas.
- Flutter 3.35 o superior.
- Clave de Google AI Studio para Gemini.
- Cuenta de RevenueCat con productos configurados en App Store Connect y
  Google Play Console.

## Backend

```powershell
cd backend
npm install
Copy-Item .env.example .env
# Edita .env con MONGODB_URI, JWT_SECRET y GEMINI_API_KEY
npm run dev
```

La API queda en `http://localhost:3000/api`.
Comprueba el servicio con `GET /api/salud`.

Variables principales:

- `MONGODB_URI`: conexión de MongoDB.
- `JWT_SECRET`: secreto largo y aleatorio para firmar tokens.
- `GEMINI_API_KEY`, `GEMINI_MODEL`: proveedor de visión.
- `REVENUECAT_SECRET_KEY`: validación de compras desde el servidor.
- `REVENUECAT_ENTITLEMENT_ID`: identificador del entitlement Premium.
- `REVENUECAT_WEBHOOK_SECRET`: secreto compartido con el webhook.
- `MAX_IMAGE_MB`: tamaño máximo de imagen.

Pruebas y verificación:

```powershell
cd backend
npm test
npm run check
```

## Flutter

```powershell
cd eduguia_app
Copy-Item .env.example .env
# Edita .env con la IP LAN de tu equipo y el puerto de tu backend
flutter pub get
flutter run
```

El archivo `.env` define la configuración de desarrollo:

- `API_URL`: URL base del backend. En un dispositivo Android físico por USB
  usa la IP LAN del equipo (por ejemplo `http://192.168.1.50:3000/api`), no
  `localhost`. En emulador Android usa `http://10.0.2.2:3000/api`; en simulador
  iOS usa `http://127.0.0.1:3000/api`. Ajusta el puerto si tu backend usa otro.
- `USE_MOCKS`: `false` (valor por defecto) usa `ApiEduGuiaRepository` contra
  Node.js; `true` vuelve a `MockEduGuiaRepository` para trabajar sin backend.
- `API_TIMEOUT_SECONDS`: tiempo máximo de espera de las llamadas HTTP.

También puedes sobrescribir valores sin tocar `.env`:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
flutter run --dart-define=EDUGUIA_USAR_MOCK=false
```

Para compras, agrega las llaves de RevenueCat:

```powershell
flutter run `
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx `
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx `
  --dart-define=REVENUECAT_ENTITLEMENT_ID=premium
```

En builds de depuración, la app crea una sesión demo con
`demo@eduguia.mx` / `demo12345` y un hijo llamado Mateo cuando no hay una
sesión guardada. Para desactivarlo:

```powershell
flutter run --dart-define=EDUGUIA_DEMO_AUTO_LOGIN=false
```

Verificación:

```powershell
cd eduguia_app
flutter analyze
flutter test
```

## Flujo principal

1. `POST /api/auth/registro` o `POST /api/auth/login` devuelve un JWT.
2. `POST /api/tareas/analizar` recibe `imagen`, `nombreHijo` y
   `materiaSugerida` como `multipart/form-data`.
3. El backend valida el plan, procesa la imagen en memoria, llama a Gemini,
   valida el JSON de respuesta y guarda solo el resultado pedagógico.
4. La app muestra el método de estudio y las preguntas guía.
5. RevenueCat activa Premium y el backend lo confirma con
   `POST /api/suscripcion/validar` o con el webhook.

## Privacidad de menores

- La imagen se procesa en memoria y se sobrescribe con ceros al terminar.
- No se guarda la foto ni una URL pública.
- El historial conserva solo materia, tema, método y preguntas guía.
- El token se guarda con `flutter_secure_storage`.
- El servidor no devuelve `passwordHash` ni datos internos.

## Estado de integración

- Backend probado con pruebas unitarias y de API; requiere MongoDB para una
  prueba de extremo a extremo real.
- Gemini y RevenueCat requieren claves y productos reales.
- En debug la app usa sesión demo; en release no hay sesión automática y falta
  una pantalla de registro/login para producción.
- Android tiene permiso de Internet y HTTP local solo en debug. iOS permite
  red local; en producción usa HTTPS.
