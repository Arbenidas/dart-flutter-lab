---
id: 'D13-L03'
trackId: 'dart'
moduleId: 'D13'
kind: 'taller'
order: 2
slug: 'la-superficie-publica-de-un-paquete'
title: 'Todo lo que exportas es una promesa'
summary: 'Decide qué forma parte de la API pública, aprende para qué existe lib/src y documenta lo que sí publicas.'
estimatedMinutes: 50
objectives:
  - 'Distinguir la API pública de un paquete de su código interno.'
  - 'Explicar para qué existe la convención lib/src.'
  - 'Escribir documentación que aporte lo que la firma no dice.'
prerequisites: ['D13-L02']
activities:
  - id: 'clasificar-rutas'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, clasifica como pública o privada: lib/bitacora.dart, lib/src/interno.dart, bin/cli.dart y lib/README.md.'
    required: true
    hints:
      - 'La convención se basa en la ruta, no en un modificador del lenguaje.'
      - 'Fuera de lib no se publica nada como API.'
  - id: 'resolver-m14-5'
    kind: 'evidence'
    prompt: 'Implementa esApiPublica con sus tres reglas. Ejecuta sus pruebas y pega la salida del caso de lib/src.'
    required: true
    hints:
      - 'Normaliza los separadores antes de comparar.'
      - 'Un archivo que no es .dart no forma parte de la API.'
  - id: 'sustentar-src'
    kind: 'source'
    prompt: 'En Creating packages, encuentra qué papel cumple lib/src y qué recomienda la documentación sobre exportar desde ahí.'
    required: true
    sourceLabel: 'Creating packages'
    hints:
      - 'Busca el encabezado sobre la organización del paquete.'
      - 'Fíjate en si menciona export.'
  - id: 'defender-documentacion'
    kind: 'judgment'
    prompt: 'Decide qué debe aportar el comentario de documentación de una función pública y qué sobra, y nombra el costo de documentar de más.'
    required: true
    hints:
      - 'Repetir el nombre y los tipos no agrega nada: ya están en la firma.'
      - 'Lo que falta suele ser qué lanza, qué garantiza y un ejemplo mínimo.'
docRefs:
  - label: 'Creating packages'
    url: 'https://dart.dev/tools/pub/create-packages'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Effective Dart: Documentation'
    url: 'https://dart.dev/effective-dart/documentation'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué código forma parte de la API pública de un paquete y qué propósito tiene lib/src?'
  - 'En un archivo vacío, vuelve a escribir esApiPublica sin mirar tu solución.'
  - 'Explica en voz alta por qué lib/src es una convención y no una barrera del lenguaje.'
  - 'Documenta una función pública tuya con promesa, retorno, errores, ejemplo y límites; elimina lo que repita la firma.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m14_paquetes.dart'
  testCommand: 'fvm dart test test/m14_paquetes_test.dart --name m14-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm14-5'
  revealReference: true
---

Publicar un paquete es firmar una promesa. Lo primero es saber **qué** estás prometiendo.

## Tres reglas de ruta

```dart
bool esApiPublica(String rutaRelativa) {
  final ruta = rutaRelativa.replaceAll(r'\', '/');
  if (!ruta.startsWith('lib/')) return false;
  if (ruta.startsWith('lib/src/')) return false;
  return ruta.endsWith('.dart');
}
```

1. Fuera de `lib/` no hay API — `bin/`, `test/`, `tool/` son tuyos.
2. `lib/src/` es interno por **convención**.
3. Solo los `.dart` cuentan.

Fíjate en la normalización de separadores: en Windows las rutas llegan con `\`. Es el mismo principio de D05-L02 —normalizar antes de comparar—, ahora sobre rutas.

## `lib/src` es una convención, no una barrera

Nada impide que alguien escriba `import 'package:tu_paquete/src/interno.dart'`. Compila. Lo que la convención dice es: **si lo haces, no te quejes cuando se rompa**.

El patrón habitual es un archivo público que reexporta lo que sí es API:

```dart
// lib/bitacora.dart
export 'src/nota.dart' show Nota;
export 'src/repositorio.dart' show RepositorioBitacora;
```

Ese `show` es la lista explícita de lo que prometes. Todo lo demás en `src/` puedes cambiarlo sin subir la versión mayor.

## Documentar lo que la firma no dice

````dart
/// Carga las notas guardadas en [origen].
///
/// Lanza [BitacoraCorrupta] si el archivo existe pero no se puede interpretar.
/// Un archivo ausente o vacío devuelve una lista vacía, que no es un error.
///
/// ```dart
/// final notas = await cargar(Uri.file('bitacora.json'));
/// ```
List<Nota> cargar(Uri origen)
````

Lo que aporta: **qué lanza**, **qué garantiza en los casos raros** y un ejemplo mínimo. Lo que sobraría: «Devuelve una lista de notas» — eso ya lo dice la firma.

## Intento · antes de mirar

Clasifica las cuatro rutas y anota, para cada una, quién puede importarla:

- `lib/bitacora.dart`
- `lib/src/interno.dart`
- `bin/cli.dart`
- `lib/README.md`

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m14_paquetes_test.dart --name m14-5
```

Pega la salida del caso de `lib/src`.

## Fuente · lee con una pregunta

Abre **Creating packages** con una pregunta concreta: ¿qué papel cumple `lib/src` y qué recomienda sobre `export`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende qué debe llevar un comentario de documentación. Documentar de más tiene un costo real: se desactualiza, y una documentación que miente es peor que ninguna.

Nombra tu criterio para qué merece un comentario y qué se explica solo. Cierra el módulo:

```bash
fvm dart analyze
```

En D14 aparece lo que llevas todo el curso necesitando: cómo saber si algo funciona de verdad.
