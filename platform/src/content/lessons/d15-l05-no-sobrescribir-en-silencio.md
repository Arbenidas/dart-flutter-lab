---
id: 'D15-L05'
trackId: 'dart'
moduleId: 'D15'
kind: 'proyecto'
order: 4
slug: 'no-sobrescribir-un-archivo-roto'
title: 'Criterio de terminado: nada se pierde en silencio'
summary: 'Comprueba que un archivo corrupto sobrevive intacto a un intento de escritura y cierra el proyecto con la puerta de calidad.'
estimatedMinutes: 60
objectives:
  - 'Demostrar con una prueba que un archivo corrupto no se sobrescribe.'
  - 'Explicar cómo el orden de las operaciones produce esa garantía.'
  - 'Ejecutar la verificación completa del laboratorio desde un clon limpio.'
prerequisites: ['D15-L04']
activities:
  - id: 'predecir-sobrescritura'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué le pasa a un archivo corrupto cuando alguien intenta crear una nota, y qué orden de operaciones produciría la pérdida.'
    required: true
    hints:
      - 'Si guardar ocurriera antes de cargar, el archivo se perdería.'
      - 'La garantía sale del orden, no de una comprobación extra.'
  - id: 'resolver-m16-6'
    kind: 'evidence'
    prompt: 'Implementa resumen y comprueba el caso corrupto. Ejecuta las pruebas del módulo completo y pega el resumen final.'
    required: true
    hints:
      - 'El resumen debe fallar ante un archivo corrupto, no devolver ceros.'
      - 'El test comprueba que el contenido original sigue intacto.'
  - id: 'sustentar-verificacion'
    kind: 'source'
    prompt: 'En Testing, encuentra cómo se ejecuta la suite completa y qué informa al terminar.'
    required: true
    sourceLabel: 'Testing'
    hints:
      - 'Busca cómo correr todas las pruebas de un paquete.'
      - 'Fíjate en qué muestra el reporte.'
  - id: 'defender-migracion'
    kind: 'judgment'
    prompt: 'Propón la migración a schemaVersion 2 sin implementarla: define qué lee, qué escribe, en qué orden y qué ocurre si falla a mitad.'
    required: true
    hints:
      - 'Escribir sobre el archivo original antes de terminar es el riesgo principal.'
      - 'Una copia previa cuesta espacio y salva el caso malo.'
docRefs:
  - label: 'Testing'
    url: 'https://dart.dev/tools/dart-test'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué cuatro elementos convierten una necesidad en un criterio de aceptación ejecutable?'
  - 'Desde un clon limpio, vuelve a ejecutar el flujo completo de la bitácora sin mirar tus notas de comandos.'
  - 'Explica en voz alta cómo el orden de cargar y guardar protege un archivo corrupto.'
  - 'Prepara una demostración desde clon limpio: crear, filtrar, completar, recuperar de un fallo y ejecutar la puerta de calidad.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m16_bitacora.dart'
  testCommand: 'fvm dart test test/m16_bitacora_test.dart --name m16-6'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm16-6'
  revealReference: true
---

Todo el proyecto apuntaba a esta garantía: **los datos de una persona no se pierden en silencio**.

## La garantía sale del orden

```dart
String? crear({required String id, required String texto, ...}) {
  // ...
  final notas = _repositorio.cargar();   // lanza si está corrupto
  // ...
  _repositorio.guardar(<Nota>[...notas, nueva]);
}
```

`cargar()` va **antes** que `guardar()`. Ante un archivo corrupto, `cargar()` lanza y la ejecución no llega nunca a escribir. El archivo original queda intacto.

No hay ninguna comprobación especial que diga «si está corrupto no escribas». La garantía es una consecuencia del orden, y por eso es difícil de romper por accidente.

El test lo fija explícitamente:

```dart
expect(() => servicio.crear(id: 'n1', texto: 'Primera'), throwsA(isA<BitacoraCorrupta>()));
expect(almacen.leer(), '{roto', reason: 'El contenido original debe seguir intacto.');
```

La segunda línea es la que importa. La primera solo dice que falló; la segunda dice que **no destruyó nada**.

## El resumen tampoco miente

```dart
({int pendientes, int completadas}) resumen() {
  var pendientes = 0;
  var completadas = 0;
  for (final nota in _repositorio.cargar()) { ... }
}
```

Ante un archivo corrupto, `resumen()` **falla**. Un `0 pendientes, 0 completadas` sería una respuesta plausible y falsa, y alguien tomaría una decisión con ella.

Fallar es incómodo y honesto. Es la misma postura de todo el módulo.

## Criterio de terminado

El proyecto está cerrado cuando esto pasa desde un clon limpio:

```bash
cd dart_lab
fvm dart pub get --enforce-lockfile
./lab verify
fvm dart analyze
fvm dart format --output=none --set-exit-if-changed .
```

`./lab verify` recorre los ejercicios en orden, se detiene en el primer fallo y termina con los contratos públicos y el análisis. Sin avisos y sin pruebas rojas.

## Intento · antes de mirar

Escribe qué le pasaría al archivo si `guardar` ocurriera **antes** de `cargar`, y qué vería el usuario la próxima vez que abriera la app.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m16_bitacora_test.dart --name m16-6
fvm dart test test/m16_bitacora_test.dart
```

Pega el resumen del archivo completo.

## Fuente · lee con una pregunta

Abre **Testing** con una pregunta concreta: ¿cómo se ejecuta la suite completa y qué informa al terminar? Anota el encabezado.

## Criterio · decide y acepta el costo

Propón la migración a `schemaVersion` 2 **sin implementarla**. Responde cuatro cosas:

1. Qué lee y qué escribe.
2. En qué orden, para no destruir el original si falla a mitad.
3. Qué pasa si el proceso muere durante la migración.
4. Cómo lo probarías sin tocar disco — ya tienes `AlmacenEnMemoria` para eso.

Esa última pregunta es la medida de todo lo que construiste: si la migración se puede probar sin un archivo real, las costuras estaban donde tenían que estar.

Con esto cierras la ruta Dart. Lo que sigue es Flutter, y todo lo que aprendiste aquí —contratos, invariantes, estados imposibles, errores honestos— sigue aplicando con otra sintaxis.
