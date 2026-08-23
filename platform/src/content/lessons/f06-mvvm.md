---
id: 'F06-L01'
trackId: 'flutter'
moduleId: 'F06'
order: 0
slug: 'proyecto-bitacora-crud-verificable'
title: 'Proyecto final: una bitácora que puedes demostrar'
summary: 'Integra el recorrido Flutter en un CRUD con repositorio en memoria, Riverpod Notifier y pruebas unitarias y de widgets.'
estimatedMinutes: 210
objectives:
  - 'Explicar y verificar el flujo completo de crear, leer, editar y eliminar una entrada.'
  - 'Probar Repository y ViewModel en aislamiento y el recorrido visible mediante un widget test.'
  - 'Evaluar los límites del repositorio en memoria y planear persistencia sin acoplar la View.'
prerequisites: ['F05-L01']
activities:
  - id: 'predecir-crud-completo'
    kind: 'predict'
    prompt: 'Antes de ejecutar, traza create, read, update y delete por archivo y predice el estado visible, el contador y el orden después de cada acción.'
    required: true
    hints:
      - 'Sigue View → ViewModel → JournalRepository y el nuevo JournalState.'
      - 'El repositorio ordena por updatedAt y luego por id.'
  - id: 'escribir-caso-borde'
    kind: 'code'
    prompt: 'Añade un caso borde del CRUD con el test más barato que dé confianza: título mayor de 80, orden tras editar o cancelación sin guardar; justifica la capa elegida.'
    required: true
    hints:
      - 'Una regla pura del ViewModel no necesita WidgetTester.'
      - 'Una interacción de diálogo sí necesita un widget test.'
  - id: 'diagnosticar-mutacion'
    kind: 'debug'
    prompt: 'Rompe temporalmente el trim del título o la recarga tras delete; predice qué test debe fallar, ejecuta solo ese archivo y explica por qué localiza el defecto.'
    required: true
    hints:
      - 'Haz un cambio pequeño y reversible.'
      - 'Restaura el comportamiento antes de terminar y vuelve a ejecutar la suite.'
  - id: 'leer-testing-oficial'
    kind: 'docs'
    prompt: 'En Testing Flutter apps, compara unidad, widget e integración; en WidgetTester localiza tap, enterText y pumpAndSettle y explica qué sincroniza cada llamada usada.'
    required: true
    hints:
      - 'Elige la capa por el riesgo, no por una pirámide aplicada mecánicamente.'
      - 'En API reference revisa firma, descripción y métodos relacionados.'
  - id: 'explicar-evidencia'
    kind: 'explain'
    prompt: 'Explica qué demuestra cada uno de los tres archivos de test del journal y qué defecto importante quedaría fuera de su alcance.'
    required: true
    hints:
      - 'Separa contrato de almacenamiento, orquestación y experiencia visible.'
      - 'Un widget test no prueba persistencia real ni un backend.'
  - id: 'transferir-persistencia'
    kind: 'transfer'
    prompt: 'Diseña el reemplazo de InMemoryJournalRepository por persistencia local o nube: conserva el contrato útil, identifica cambios asíncronos y define las pruebas nuevas.'
    required: true
    hints:
      - 'La memoria se pierde al reiniciar; no la presentes como almacenamiento duradero.'
      - 'Mantén la View independiente de la tecnología elegida.'
docRefs:
  - label: 'Testing Flutter apps'
    url: 'https://docs.flutter.dev/testing/overview'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'WidgetTester class'
    url: 'https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'UI layer case study'
    url: 'https://docs.flutter.dev/app-architecture/case-study/ui-layer'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué archivo protege cada responsabilidad del CRUD y por qué?'
  - '¿Cuándo basta pump y cuándo necesitas pumpAndSettle?'
  - '¿Qué limitaciones funcionales tiene InMemoryJournalRepository?'
  - '¿Qué debe permanecer estable al cambiar memoria por persistencia real?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal'
  testCommand: 'fvm flutter test test/features/journal'
  analyzeCommand: 'fvm flutter analyze'
---

El proyecto final no consiste en añadir otra capa. Consiste en demostrar que puedes seguir una decisión desde la interacción hasta los datos, comprobarla en la capa adecuada y reconocer qué falta antes de llamar «terminada» a una aplicación.

La bitácora del starter contiene una vertical completa:

```text
JournalView / JournalEditorDialog
              ↓ eventos
JournalViewModel → JournalState
              ↓ contrato
JournalRepository
              ↓ implementación actual
InMemoryJournalRepository
```

El alcance es deliberado: crear, listar, editar y eliminar entradas durante la sesión. El repositorio en memoria no persiste tras reiniciar y no simula red. Esa limitación debe verse en el producto y en tu explicación técnica.

## Inventario antes de programar

Lee los archivos por responsabilidad, no en orden alfabético:

1. `journal_repository.dart`: contrato del dato.
2. `in_memory_journal_repository.dart`: almacenamiento, identidad y orden.
3. `journal_state.dart`: estado que observa la View.
4. `journal_view_model.dart`: validación, comandos y publicación.
5. `journal_view.dart` y `journal_editor_dialog.dart`: composición e interacción.
6. Los tres archivos de test correspondientes.

Para cada método registra entrada, salida, efectos y fallo. Por ejemplo, `update` exige un id existente, conserva `createdAt`, cambia `updatedAt` y lanza `StateError` si no encuentra el registro. Esa lectura produce casos de prueba mejores que mirar solo la UI.

## El flujo de cada operación

### Create

El diálogo toma texto, el ViewModel hace `trim` y valida el título, el Repository crea identidad y timestamps, y el Notifier publica una lista nueva. La View observa el estado y cambia de vacío a contenido.

### Read

`getAll` devuelve una lista no modificable ordenada por actualización descendente. «Read» no necesita un botón: ocurre al construir el estado y después de cada mutación.

### Update

La View abre el mismo editor con una entrada. El Repository conserva identidad y fecha de creación, actualiza contenido y `updatedAt`. El orden puede cambiar; ese comportamiento merece una prueba si es requisito.

### Delete

La View solicita confirmación. Solo `true` ejecuta el comando. El Repository falla explícitamente para ids inexistentes; el ViewModel publica una lista sin la entrada; el contador y el estado vacío se reconstruyen.

## Tres capas de evidencia

### Test unitario del Repository

`in_memory_journal_repository_test.dart` verifica CRUD, tiempo controlable, orden y errores del almacenamiento sin Flutter UI. El reloj inyectado elimina dependencia del tiempo real.

### Test unitario del ViewModel

`journal_view_model_test.dart` crea un `ProviderContainer`, sustituye el provider de Repository y comprueba normalización, validación y comandos. Es la capa adecuada para una regla como «título requerido».

### Widget test de la View

`journal_view_test.dart` monta `FlutterLabApp` dentro de `ProviderScope`, usa keys públicas, escribe como una persona y verifica crear, editar, confirmar borrado y mostrar validación. Protege la coordinación visible que un unit test no puede representar.

La documentación oficial describe unidad, widget e integración como alcances distintos. «Más alto» no significa siempre «mejor»: elige el test más barato que capture el riesgo. Conserva unos pocos recorridos amplios para comprobar que las piezas colaboran.

## Entender pump

En un widget test, `tap` o `enterText` no avanzan automáticamente todos los frames. `pump` procesa un frame; `pumpAndSettle` repite hasta que no quedan frames programados, útil para abrir o cerrar diálogos con animación.

No uses `pumpAndSettle` como remedio ciego. Una animación infinita puede impedir que termine y una espera excesiva oculta qué transición necesitas. Lee la API de `WidgetTester`, identifica el trabajo programado por la interacción y usa la espera mínima que exprese el contrato.

## P — Predice

Sin ejecutar, construye una tabla para esta secuencia: lista vacía, crear A, crear B, editar A, eliminar B. Predice contador, primer elemento y estado vacío tras cada paso. Revisa el comparador de `getAll` para decidir el orden, no lo adivines por el orden de inserción.

Traza además qué test debería detectar un fallo en cada etapa. Si todo depende del widget test más largo, falta aislamiento.

## E — Escribe

Elige un caso borde aún no protegido:

- título de más de 80 caracteres en ViewModel;
- reordenamiento después de editar en Repository;
- cancelar el diálogo conserva la lista en View;
- cancelar confirmación no elimina.

Escribe primero el comportamiento esperado en una frase y elige la capa. Usa Arrange–Act–Assert sin convertir el test en una copia de la implementación. Después ejecuta solo ese archivo para obtener feedback rápido.

## N — Nombra el fallo

Realiza una mutación pequeña y reversible: elimina temporalmente `trim()` o comenta `_reload()` después de borrar. Antes de ejecutar, predice exactamente cuál aserción falla. Ejecuta el test mínimo, observa el mensaje y relaciona síntoma con responsabilidad.

Restaura el código inmediatamente y ejecuta la suite completa. El propósito no es dejar un defecto ni «engañar» cobertura; es comprobar que el test detecta la regresión que promete.

## S — Sustenta

En **Testing Flutter apps**, empieza por la tabla comparativa y formula: «¿qué entorno necesito para este riesgo?». Sigue el enlace de widget testing solo cuando la interacción lo exija. En la API de `WidgetTester`, busca el método concreto usado, lee su firma y revisa qué devuelve.

La documentación no reemplaza observar un fallo. Combina tres evidencias: contrato oficial, test rojo por la razón prevista y test verde tras restaurar. Registra comando y resultado; una captura sin comando ni versión es difícil de reproducir.

## A — Argumenta

Explica por qué el CRUD del ViewModel merece unit tests aunque exista un widget test completo. Las reglas se localizan más rápido, no dependen de animaciones y pueden cubrir bordes baratos. Explica también por qué al menos un widget test sigue siendo necesario: valida que campos, botones, diálogos y estado observable están conectados.

Nombra lo que esta suite no demuestra: persistencia tras reinicio, comportamiento en dispositivo real, backend, conectividad, lector de pantalla y rendimiento bajo volumen. La honestidad sobre alcance es parte de la evidencia.

## R — Reaplica

Planea una versión persistente sin tocar la View primero. Decide si el contrato del Repository será asíncrono, cómo representarás loading/error, qué Service encapsulará SQLite o nube y cómo migrarás datos. Conserva modelos y comandos que sigan siendo válidos.

Añade unit tests del nuevo Service/Repository con una base temporal o fake, contract tests compartidos entre implementaciones y un widget test del estado de recuperación. No prometas offline ni sincronización hasta que existan esos estados y pruebas.

## Criterio de terminado

Desde `flutter_lab/`, completa:

```bash
fvm flutter test test/features/journal/data/in_memory_journal_repository_test.dart
fvm flutter test test/features/journal/presentation/journal_view_model_test.dart
fvm flutter test test/features/journal/presentation/journal_view_test.dart
fvm flutter test test/features/journal
fvm flutter analyze
```

Terminas cuando todos pasan y puedes explicar qué contrato protege cada uno, no solo cuando la terminal queda verde.
