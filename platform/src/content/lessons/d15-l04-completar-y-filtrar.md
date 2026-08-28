---
id: 'D15-L04'
trackId: 'dart'
moduleId: 'D15'
kind: 'proyecto'
order: 3
slug: 'completar-y-filtrar-notas'
title: 'Consultar y modificar sin reescribir de más'
summary: 'Marca una nota como completada solo cuando hay algo que cambiar, y filtra usando la misma normalización que al guardar.'
estimatedMinutes: 50
objectives:
  - 'Implementar una operación idempotente sobre datos persistidos.'
  - 'Evitar escrituras innecesarias cuando nada cambió.'
  - 'Filtrar con la misma normalización con la que se guardó.'
prerequisites: ['D15-L03']
activities:
  - id: 'predecir-completar'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería devolver completar en tres casos y si debería escribir el archivo cuando no cambió nada.'
    required: true
    hints:
      - 'Escribir sin cambios gasta E/S y arriesga corromper un archivo intacto.'
      - 'Recuerda la idempotencia de D14-L03.'
  - id: 'resolver-m16-5'
    kind: 'evidence'
    prompt: 'Implementa completar y filtrarPorEtiqueta. Ejecuta sus pruebas y pega la salida del caso de la segunda llamada.'
    required: true
    hints:
      - 'Recorre las notas produciendo la lista nueva y anota si hubo cambio.'
      - 'Filtra normalizando la etiqueta buscada igual que al crear.'
  - id: 'sustentar-inmutabilidad'
    kind: 'source'
    prompt: 'En Collections, repasa cómo producir una lista transformada sin mutar la original.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca map y toList.'
      - 'Conecta con lo que hiciste en D04-L05.'
  - id: 'defender-escritura'
    kind: 'judgment'
    prompt: 'Decide si conviene escribir siempre o solo cuando hubo cambio, y nombra el riesgo de cada opción.'
    required: true
    hints:
      - 'Escribir siempre simplifica el código y multiplica las oportunidades de corromper.'
      - 'Escribir condicionalmente exige rastrear si algo cambió.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué completar una nota ya completada no debería escribir el archivo?'
  - 'En un archivo vacío, vuelve a escribir completar y filtrarPorEtiqueta, sin mirar tu solución.'
  - 'Explica en voz alta por qué el filtro debe normalizar igual que la creación.'
  - 'Agrega una operación de descompletar y decide si rompe la idempotencia.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m16_bitacora.dart'
  testCommand: 'fvm dart test test/m16_bitacora_test.dart --name m16-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm16-5'
---

Modificar datos persistidos tiene un riesgo que los datos en memoria no tienen: cada escritura es una oportunidad de dejar el archivo a medias.

## Escribir solo si cambió

```dart
bool completar(String id) {
  final notas = _repositorio.cargar();
  var cambio = false;
  final actualizadas = notas.map((nota) {
    if (nota.id == id && !nota.completada) {
      cambio = true;
      return nota.copyWith(completada: true);
    }
    return nota;
  }).toList(growable: false);
  if (cambio) {
    _repositorio.guardar(actualizadas);
  }
  return cambio;
}
```

Tres cosas ocurren aquí:

1. **Se produce una lista nueva**, no se muta la original — D04-L05.
2. **Se registra si hubo cambio** mientras se recorre, sin una segunda pasada.
3. **Solo se escribe si cambió.** Completar algo ya completado no toca el disco.

Ese tercer punto no es una micro-optimización. Cada escritura es un momento en que el proceso puede morir a mitad y dejar el archivo truncado. No escribir es la operación más segura que existe.

## El mismo criterio al filtrar

```dart
List<Nota> filtrarPorEtiqueta(String etiqueta) {
  final buscada = etiqueta.trim().toLowerCase();
  return _repositorio.cargar().where((nota) => nota.etiquetas.contains(buscada)).toList(growable: false);
}
```

`buscada` se normaliza igual que al crear. Si una se olvidara, buscar `'Dart'` no encontraría nada y el usuario concluiría que la nota no existe.

Esta es la razón concreta por la que la normalización duplicada de la lección anterior es un riesgo real y no una cuestión de estilo.

## Intento · antes de mirar

Completa la tabla antes de tocar el archivo:

| Llamada                          | Devuelve | ¿Escribe? |
| -------------------------------- | -------- | --------- |
| primera sobre una nota pendiente | ?        | ?         |
| segunda sobre la misma           | ?        | ?         |
| sobre un id inexistente          | ?        | ?         |

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m16_bitacora_test.dart --name m16-5
```

Pega la salida del caso de la segunda llamada.

## Fuente · lee con una pregunta

Vuelve a **Collections** con una pregunta concreta: ¿cómo se produce una lista transformada sin mutar la original? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende escribir solo cuando hubo cambio. La alternativa es más simple de escribir y de leer, y multiplica las oportunidades de corromper el archivo.

Nombra el costo de tu elección: rastrear `cambio` ensucia el recorrido. En la última lección se comprueba lo que este proyecto vino a demostrar.
