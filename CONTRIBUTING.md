# Contribuir a Dart & Flutter Lab

Gracias por ayudar a construir una ruta de aprendizaje clara para personas que comienzan desde cero. Puedes contribuir con contenido, laboratorios, accesibilidad, diseño, pruebas, documentación o correcciones pequeñas.

Al participar aceptas el [Código de conducta](CODE_OF_CONDUCT.md) y que tu contribución se publique bajo la [licencia MIT](LICENSE).

## Antes de comenzar

1. Busca si ya existe un issue relacionado.
2. Para una corrección pequeña, puedes abrir directamente un pull request.
3. Para un módulo nuevo, un cambio de arquitectura o una dependencia adicional, abre primero una propuesta. Así evitamos trabajo que después no encaje con la ruta pedagógica.
4. Nunca publiques secretos, datos personales ni reportes de seguridad en un issue público. Sigue [SECURITY.md](SECURITY.md).

## Preparar el entorno

Necesitas FVM, Flutter `3.47.1`, Dart `3.13.x`, Node.js `24.16.0` y npm `11.13.0`.

```sh
git clone https://github.com/Arbenidas/dart-flutter-lab.git
cd dart-flutter-lab
fvm install
./tool/preflight.sh

cd platform
npm ci
npm run dev
```

Para ejecutar la matriz web completa por primera vez:

```sh
npx playwright install chromium firefox webkit
```

## Elige un tipo de contribución

### Contenido educativo

- Lee [la guía curricular](docs/CURRICULUM.md).
- Define los términos antes de usarlos y asume cero conocimiento previo.
- Conserva la secuencia PENSAR: Predice, Escribe, Nombra, Sustenta, Argumenta y Reaplica.
- Usa fuentes oficiales de Dart, Flutter o paquetes; registra versión y fecha de verificación.
- No menciones un archivo local sin incluirlo, enlazar su descarga o explicar explícitamente que el estudiante debe crearlo.
- Evita introducir una abstracción antes de que resuelva un problema que el estudiante ya reconoce.

Valida cualquier cambio de contenido con:

```sh
cd platform
npm run check:content
npm run check
```

### Plataforma Astro

- Mantén la teoría, ejemplos, navegación y fuentes disponibles sin JavaScript.
- Usa JavaScript solo como mejora progresiva para progreso, notas, pistas, búsqueda y repasos.
- Conserva HTML semántico, foco visible, teclado completo, objetivos táctiles y contraste WCAG 2.2 AA.
- No añadas React, Angular, Vue u otro runtime de interfaz sin una propuesta aceptada.
- Toda dependencia nueva necesita una justificación de mantenimiento, tamaño y seguridad.

### Dart Lab

- Conserva IDs, firmas públicas y `TODO` del starter salvo que el issue aprobado cambie el contrato.
- Actualiza en conjunto starter, solución canónica, contratos, verificaciones estructurales y mutantes.
- Los ejercicios incompletos deben fallar de forma pedagógica; no hagas que los `TODO` iniciales rompan la CI.
- Usa únicamente el SDK fijado. No reemplaces silenciosamente `fvm dart` por el Dart global.

```sh
cd dart_lab
fvm dart pub get --enforce-lockfile
fvm dart format .
fvm dart analyze
fvm dart run tool/verify_reference.dart
fvm dart test test/public_contract_test.dart
```

### Flutter Lab

- Organiza por funcionalidad y separa `View → ViewModel → Repository`.
- La View presenta estado y envía eventos; no accede directamente a red, almacenamiento o repositorios.
- El ViewModel contiene estado y lógica de presentación; el Repository es la frontera de datos.
- Añade capas de dominio solo cuando exista lógica compleja compartida.
- Acompaña cambios de comportamiento con pruebas unitarias o de widgets.

```sh
cd flutter_lab
fvm flutter pub get --enforce-lockfile
fvm dart format lib test
fvm flutter analyze
fvm flutter test
fvm flutter build web --release
```

## Flujo de trabajo

1. Crea una rama desde `main`: `fix/d00-ruta-archivo`, `content/d05-iterables` o `feat/repasos-accesibles`.
2. Haz commits pequeños y descriptivos.
3. Ejecuta las comprobaciones del área modificada.
4. Actualiza documentación, contenido y pruebas cuando cambie un contrato.
5. Abre un pull request usando la plantilla y enlaza el issue con `Closes #123` cuando corresponda.
6. Responde a la revisión con cambios nuevos; evita reescribir la historia mientras hay una revisión activa.

## Criterios para aceptar un pull request

Un PR está listo cuando:

- resuelve un problema concreto y mantiene un alcance revisable;
- la CI está verde;
- el recorrido de una persona principiante sigue siendo comprensible;
- no rompe IDs permanentes ni datos locales sin migración;
- incluye pruebas proporcionales al riesgo;
- cumple accesibilidad y funciona desde 320 px;
- explica decisiones y alternativas descartadas;
- no contiene archivos generados, secretos ni cambios ajenos al objetivo.

Las decisiones pedagógicas y de arquitectura se revisan por claridad, mantenibilidad y evidencia oficial, no por preferencia personal.
