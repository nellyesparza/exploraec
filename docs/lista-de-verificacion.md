# Lista de verificación del Proyecto Final

Es la rúbrica de `final-project/rubric.md` convertida en preguntas que puedes comprobar tú antes de subir tu entrega. Márcala con tu proyecto abierto, no de memoria. Cada punto dice **qué mirar**.

## 1. Persistencia remota o funcionalidad colaborativa (20 %)

- [ ] Puedo **crear, ver y eliminar** un dato de mi dominio desde la app y queda guardado en mi backend o en Firebase. *Mira:* el registro del servidor o su consola.
- [ ] Sin sesión, esa funcionalidad se rechaza (401 o regla de seguridad). *Mira:* cerrar sesión e intentarlo.

## 2. Autenticación (15 %)

- [ ] Registro, inicio y cierre de sesión funcionan. *Mira:* hacerlos con un usuario nuevo.
- [ ] El token se guarda con almacenamiento seguro y la sesión sobrevive al reinicio.

## 3. Datos reales (15 %)

- [ ] La lista principal sale de una fuente real o de al menos 15-20 registros en mi backend, Firebase o Hive; no está escrita a mano en el código.

## 4. Persistencia local (10 %)

- [ ] Una funcionalidad (favoritos, historial, borradores) **sobrevive al cierre completo** de la app. *Mira:* cerrar la app de «recientes» y abrirla.

## 5. Estado con GetX (10 %)

- [ ] El estado compartido entre pantallas vive en controladores, no repetido con `setState` en cada pantalla. *Mira:* buscar `setState` en `lib/screens/`.

## 6. IA sin secretos (10 %)

- [ ] El asistente llama a **mi servidor**, no al proveedor. *Mira:* la dirección que usa la app.
- [ ] No hay claves en el repositorio:

  ```bash
  grep -rniE "api[_-]?key|sk-[a-z0-9]{10}|secret" lib .env.example
  ```

- [ ] `.env` está en `.gitignore` y nunca se subió:

  ```bash
  git check-ignore -v .env
  git log --all --oneline -- .env
  ```

## 7. Manejo de errores (10 %)

- [ ] Cada pantalla con datos muestra **carga, vacío y error** distintos. *Mira:* apagar el backend y recorrer las pantallas.
- [ ] Con un backend HTTP: 401, 400, 422, 5xx y «sin conexión» muestran mensajes distintos.
- [ ] Un error inesperado no deja una pantalla roja ni blanca (`ReporteErrores.instalar()` o equivalente).

## 8. Arquitectura y legibilidad (5 %)

- [ ] Ninguna pantalla llama directo a HTTP o Firestore: pasa por un controlador y un servicio.
- [ ] Los nombres siguen la terminología del curso y hay pruebas que pasan:

  ```bash
  flutter test
  ```

## 9. Documentación y entrega (5 %)

- [ ] El `README.md` sigue la plantilla (`docs/README-plantilla.md`) y alguien que no conoce mi proyecto podría ejecutarlo.
- [ ] El repositorio tiene **historial real de commits** (no uno solo al final).
- [ ] Hay un Release con el APK descargable, generado por GitHub Actions.
- [ ] La entrega en Moodle incluye el enlace al repositorio, el enlace al Release y el README.

## Antes de subir

- [ ] Repasé las nueve secciones con la app abierta.
- [ ] Probé el APK en un emulador limpio, siguiendo mi propio README.
