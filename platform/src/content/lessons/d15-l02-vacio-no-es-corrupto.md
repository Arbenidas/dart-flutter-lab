---
id: 'D15-L02'
trackId: 'dart'
moduleId: 'D15'
kind: 'proyecto'
order: 1
slug: 'vacio-no-es-lo-mismo-que-corrupto'
title: 'Un archivo roto no es una bitácora vacía'
summary: 'Distingue las cinco formas de fallar al leer y protege el caso que borraría los datos del usuario.'
estimatedMinutes: 60
objectives:
  - 'Distinguir un almacén vacío de uno con contenido inválido.'
  - 'Validar la versión del esquema antes de interpretar los datos.'
  - 'Explicar por qué tratar lo corrupto como vacío es el peor fallo posible.'
prerequisites: ['D15-L01']
activities:
  - id: 'clasificar-lecturas'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, clasifica como vacío o corrupto: un almacén sin escribir, un texto en blanco, un JSON roto, un objeto sin schemaVersion y una versión 99.'
    required: true
    hints:
      - 'Nunca haber escrito nada es distinto de haber escrito algo ilegible.'
      - 'Una versión más nueva significa que este programa no sabe leerla.'
  - id: 'resolver-m16-2'
    kind: 'evidence'
    prompt: 'Implementa cargar con sus cinco casos. Ejecuta sus pruebas y pega la salida del caso de la versión 99.'
    required: true
    hints:
      - 'Contenido nulo o en blanco es una bitácora vacía legítima.'
      - 'Todo lo demás que no se pueda interpretar es BitacoraCorrupta.'
  - id: 'sustentar-esquema'
    kind: 'source'
    prompt: 'En Using JSON, encuentra qué recomienda sobre versionar el formato de los datos que se guardan.'
    required: true
    sourceLabel: 'Using JSON'
    hints:
      - 'Busca si menciona compatibilidad o migración.'
      - 'Si no lo cubre, anótalo y explica por qué el proyecto lo agrega igual.'
  - id: 'defender-version-nueva'
    kind: 'judgment'
    prompt: 'Decide qué hacer ante un archivo con una versión más nueva que la soportada, y nombra el riesgo de intentar leerlo de todas formas.'
    required: true
    hints:
      - 'Leer un formato que no conoces puede perder campos al volver a escribir.'
      - 'Rechazar bloquea al usuario que abrió la app vieja por error.'
docRefs:
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo evita el diseño que un JSON corrupto sea interpretado como estado vacío?'
  - 'En un archivo vacío, vuelve a escribir cargar con sus cinco casos, sin mirar tu solución.'
  - 'Explica en voz alta por qué una versión de esquema más nueva es un fallo y no un detalle.'
  - 'Diseña la migración de schemaVersion 1 a 2 sin implementarla: qué lee, qué escribe y qué pasa si falla a mitad.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m16_bitacora.dart'
  testCommand: 'fvm dart test test/m16_bitacora_test.dart --name m16-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm16-2'
---

Esta es la lección más importante del proyecto, y trata sobre un solo bug: **confundir «no hay nada» con «no lo entiendo»**.

## Por qué es el peor fallo posible

Si `cargar()` devuelve una lista vacía ante un archivo ilegible, la app arranca mostrando la bitácora vacía. El usuario crea una nota. La app guarda **una** nota. Y las noventa y nueve anteriores, que seguían ahí en un archivo que nadie supo leer, desaparecen para siempre.

Ningún test del camino feliz detecta esto. Es un fallo de diseño, no de implementación.

## Cinco entradas, dos categorías

```dart
List<Nota> cargar() {
  final contenido = _almacen.leer();
  if (contenido == null || contenido.trim().isEmpty) {
    return const <Nota>[];              // vacío legítimo
  }

  final Object? decodificado;
  try {
    decodificado = jsonDecode(contenido);
  } on FormatException {
    throw const BitacoraCorrupta('El archivo no es JSON válido');
  }

  if (decodificado is! Map<String, Object?>) {
    throw const BitacoraCorrupta('La raíz debe ser un objeto');
  }
  final version = decodificado['schemaVersion'];
  if (version is! int) {
    throw const BitacoraCorrupta('Falta schemaVersion');
  }
  if (version > schemaVersion) {
    throw BitacoraCorrupta('Versión $version más nueva que la soportada ($schemaVersion)');
  }
  final notas = decodificado['notas'];
  if (notas is! List<Object?>) {
    throw const BitacoraCorrupta('notas debe ser una lista');
  }
  return notas.map(Nota.desdeJson).toList(growable: false);
}
```

| Entrada             | Resultado |
| ------------------- | --------- |
| sin escribir        | vacío     |
| solo espacios       | vacío     |
| `{roto`             | corrupto  |
| sin `schemaVersion` | corrupto  |
| `schemaVersion: 99` | corrupto  |

Solo las dos primeras son «no hay nada». Todo lo demás es «no lo entiendo».

## La versión del esquema

`schemaVersion` está en el archivo desde el día uno, y eso es lo que permite cambiar el formato después sin adivinar.

Una versión **más nueva** que la soportada es un fallo, no un detalle: significa que una versión posterior del programa escribió campos que esta no conoce. Leer el archivo de todas formas y volver a escribirlo **borraría** esos campos.

Una versión más vieja sí se puede leer: para eso se guarda el número, para saber qué migración aplicar.

## Intento · antes de mirar

Clasifica las cinco entradas de la tabla antes de tocar el archivo, y escribe qué le pasaría a un usuario en cada caso si el código devolviera lista vacía siempre.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m16_bitacora_test.dart --name m16-2
fvm dart test test/m16_bitacora_test.dart --name m16-3
```

Pega la salida del caso de la versión 99.

## Fuente · lee con una pregunta

Abre **Using JSON** y busca si menciona versionado o compatibilidad. Si no lo cubre, anótalo: **la documentación no cubre todo**, y saber dónde termina también es lectura de documentación.

## Criterio · decide y acepta el costo

Defiende rechazar una versión más nueva. El costo: un usuario que abrió la versión vieja de la app por error queda bloqueado.

Nombra qué le dirías —el mensaje seguro de D09-L05— y qué salida le darías. En la próxima lección aparecen las reglas de negocio.
