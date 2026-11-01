# <Nombre de tu app>

> Plantilla de `README.md` del Proyecto Final (Sesión 10). Copia este archivo a la raíz de **tu** proyecto como `README.md`, reemplaza todo lo que está entre `< >` y borra esta nota. Quien te evalúe va a seguir este archivo para ejecutar tu app: escríbelo pensando en alguien que no conoce tu proyecto.

<Una o dos frases: qué hace la app y para quién.>

## Capturas de pantalla

<Al menos 3 imágenes: la lista principal, la pantalla de inicio de sesión y la funcionalidad de IA. Guárdalas en `docs/capturas/` y enlázalas aquí.>

## Qué incluye

- [ ] Registro e inicio de sesión (<JWT con backend propio / Firebase>)
- [ ] Lista principal con estados de carga, vacío y error
- [ ] Persistencia local que sobrevive al reinicio (<favoritos / historial / borradores>)
- [ ] Datos remotos protegidos por autorización (<tu entidad>)
- [ ] Asistente con IA mediante un servidor intermedio, sin claves en la app
- [ ] Estado compartido con GetX

## Cómo ejecutarla

Requisitos: Flutter <versión>, <Docker / Node / otro>.

1. **Backend** (si tu proyecto lo usa):

   ```bash
   <comandos para levantarlo, uno por línea>
   ```

2. **App:**

   ```bash
   flutter pub get
   flutter run
   ```

3. **Direcciones por entorno.** Emulador Android: `<valor por defecto>`. Dispositivo físico o iOS: `<cómo cambiarlas con --dart-define>`.

## APK

Descárgalo desde la sección **Releases** de este repositorio (`<enlace>`). Se genera con GitHub Actions al subir una etiqueta `v*` (ver `.github/workflows/release-apk.yml`). Para probarlo, instálalo en un emulador con el backend encendido como se explica arriba.

## Arquitectura

```text
screens/      pantallas (solo interfaz)
controllers/  estado con GetX
services/     llamadas HTTP y almacenamiento seguro
repositories/ combinan servidor y caché local
models/       datos de <tu dominio>
```

<Un párrafo: cómo viaja un dato desde el servidor hasta la pantalla en tu app.>

## Decisión técnica propia

<Una decisión que tomaste tú y por qué: por ejemplo, de dónde salen tus datos, por qué elegiste ese backend o cómo resolviste un problema real.>

## Tecnologías

<Lista de paquetes principales y para qué se usa cada uno.>

## Seguridad

- No hay claves ni secretos en el repositorio (`.env` está en `.gitignore`).
- El token de sesión se guarda con almacenamiento seguro y nunca se imprime.
- La clave de IA, si existe, vive solo en el servidor.

## Créditos y licencias

<Fuentes de datos, imágenes o código de terceros, con su licencia.>
