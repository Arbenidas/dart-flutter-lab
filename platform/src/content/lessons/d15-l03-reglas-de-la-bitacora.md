---
id: 'D15-L03'
trackId: 'dart'
moduleId: 'D15'
kind: 'proyecto'
order: 2
slug: 'las-reglas-de-la-bitacora'
title: 'Las reglas viven donde no se pueden esquivar'
summary: 'Implementa la creación de una nota con validación, normalización de etiquetas y control de duplicados.'
estimatedMinutes: 55
objectives:
  - 'Validar y normalizar en la capa de servicio antes de persistir.'
  - 'Reutilizar la normalización de etiquetas de forma coherente.'
  - 'Impedir identificadores duplicados sin recorrer dos veces.'
prerequisites: ['D15-L02']
activities:
  - id: 'predecir-reglas'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe las tres reglas de crear y decide dónde deben vivir para que ninguna forma de crear una nota pueda esquivarlas.'
    required: true
    hints:
      - 'Una regla en la CLI no protege a quien importe notas desde otro lado.'
      - 'Las etiquetas necesitan la misma normalización que en la búsqueda.'
  - id: 'resolver-m16-4'
    kind: 'evidence'
    prompt: 'Implementa crear con su validación y su normalización de etiquetas. Ejecuta sus pruebas y pega la salida del caso de etiquetas duplicadas.'
    required: true
    hints:
      - 'Recorta, pasa a minúsculas, descarta vacías y deduplica, como en m06-2.'
      - 'Si la nota se rechaza, no se debe escribir nada.'
  - id: 'sustentar-normalizacion'
    kind: 'source'
    prompt: 'En Collections, repasa cómo se deduplica una colección conservando solo los valores normalizados.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca la sección de sets.'
      - 'Conecta lo que leas con lo que hiciste en D05-L02.'
  - id: 'defender-donde-validar'
    kind: 'judgment'
    prompt: 'Decide si la validación debe estar en el servicio, en la CLI o en las dos, y nombra el costo de duplicarla.'
    required: true
    hints:
      - 'La CLI puede avisar antes y no puede garantizar nada.'
      - 'Duplicar la regla la deja en dos sitios que pueden desincronizarse.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Dónde deben vivir las reglas para que ninguna forma de crear una nota pueda esquivarlas?'
  - 'En un archivo vacío, vuelve a escribir crear con sus tres reglas, sin mirar tu solución.'
  - 'Explica en voz alta por qué las etiquetas se normalizan igual al crear y al buscar.'
  - 'Agrega una cuarta regla a crear y decide si cabe en el mismo método.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m16_bitacora.dart'
  testCommand: 'fvm dart test test/m16_bitacora_test.dart --name m16-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm16-4'
---

Con el modelo y la persistencia resueltos, el servicio pone las reglas.

## Tres reglas, un solo lugar

```dart
String? crear({required String id, required String texto, List<String> etiquetas = const <String>[]}) {
  final normalizado = texto.trim();
  if (normalizado.isEmpty) {
    return 'La nota no puede estar vacia.';
  }
  final notas = _repositorio.cargar();
  if (notas.any((nota) => nota.id == id)) {
    return 'Ya existe una nota con ese identificador.';
  }
  final limpias = etiquetas
      .map((etiqueta) => etiqueta.trim().toLowerCase())
      .where((etiqueta) => etiqueta.isNotEmpty)
      .toSet()
      .toList(growable: false);
  _repositorio.guardar(<Nota>[
    ...notas,
    Nota(id: id, texto: normalizado, etiquetas: limpias, completada: false),
  ]);
  return null;
}
```

Fíjate en el orden: la validación barata primero, después la lectura del repositorio, y el `guardar` al final. Si rechaza, no se escribió nada — D14-L02.

## Las etiquetas, otra vez

La normalización es exactamente la de D05-L02: recortar, minúsculas, descartar vacías, deduplicar. Y tiene que ser **la misma** que usa `filtrarPorEtiqueta`, o buscar `'Dart'` no encontraría una nota etiquetada `'dart'`.

Que la regla aparezca dos veces en el código es una señal. Extraerla a una función es el refactor natural, y este ejercicio la deja duplicada a propósito para que la veas.

## Cargar antes de guardar

`crear` llama a `cargar()` antes de escribir. Eso tiene una consecuencia que la última lección aprovecha: **si el archivo está corrupto, crear falla** en vez de sobrescribirlo.

No es un efecto secundario feliz; es la razón por la que el orden es ese.

## Intento · antes de mirar

Escribe las tres reglas y, para cada una, dónde tendría que vivir para que una importación masiva tampoco pudiera esquivarla.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m16_bitacora_test.dart --name m16-4
```

Pega la salida del caso de las etiquetas duplicadas.

## Fuente · lee con una pregunta

Vuelve a **Collections**, sección de sets, con una pregunta concreta: ¿qué garantiza `toSet()` sobre los valores ya normalizados? Anota el encabezado y conéctalo con D05-L02.

## Criterio · decide y acepta el costo

Defiende dónde va la validación. La CLI puede avisar antes —mejor experiencia— y no puede garantizar nada. El servicio garantiza y llega tarde.

Nombra tu postura sobre tenerla en los dos sitios y el costo de que se desincronicen. En la próxima lección la bitácora se consulta.
