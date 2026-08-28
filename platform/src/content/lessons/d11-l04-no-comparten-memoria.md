---
id: 'D11-L04'
trackId: 'dart'
moduleId: 'D11'
kind: 'taller'
order: 3
slug: 'los-isolates-no-comparten-memoria'
title: 'Lo que cruza la frontera es una copia'
summary: 'Comprueba que una mutación hecha en otro isolate no se ve desde aquí, y entiende qué garantía compra eso.'
estimatedMinutes: 45
objectives:
  - 'Demostrar que dos isolates no comparten objetos.'
  - 'Explicar qué problema de concurrencia elimina el aislamiento de memoria.'
  - 'Reconocer el costo de copiar estructuras grandes.'
prerequisites: ['D11-L03']
activities:
  - id: 'predecir-copia'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué contiene la lista original después de que otro isolate le agregue un elemento a lo que recibió.'
    required: true
    hints:
      - 'Si fuera el mismo objeto, la mutación se vería de los dos lados.'
      - 'Compara con lo que pasaría entre dos hilos que sí comparten memoria.'
  - id: 'resolver-m12-4'
    kind: 'evidence'
    prompt: 'Implementa noCompartenMemoria y ejecuta sus pruebas. Pega la salida del test que comprueba que son dos objetos distintos.'
    required: true
    hints:
      - 'Devuelve un record con las dos listas para poder compararlas.'
      - 'identical responde si son el mismo objeto, no si tienen lo mismo.'
  - id: 'sustentar-aislamiento'
    kind: 'source'
    prompt: 'En Isolates, encuentra qué garantiza el aislamiento de memoria y qué problemas de concurrencia evita.'
    required: true
    sourceLabel: 'Isolates'
    hints:
      - 'Busca la explicación del modelo de memoria.'
      - 'Fíjate si menciona condiciones de carrera o cerrojos.'
  - id: 'defender-aislamiento'
    kind: 'judgment'
    prompt: 'Decide si el aislamiento de memoria es una ventaja o una limitación para tu caso, y nombra qué se vuelve imposible y qué se vuelve innecesario.'
    required: true
    hints:
      - 'Sin memoria compartida no hacen falta cerrojos ni secciones críticas.'
      - 'Tampoco se puede compartir una caché grande entre isolates.'
docRefs:
  - label: 'Isolates'
    url: 'https://dart.dev/language/isolates'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué memoria comparten dos isolates y cómo intercambian información?'
  - 'En un archivo vacío, vuelve a escribir noCompartenMemoria sin mirar tu solución.'
  - 'Explica en voz alta qué problema de concurrencia elimina el aislamiento.'
  - 'Diseña una importación que solo mueva el parseo a un isolate cuando el tamaño supere un umbral medido.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m12_isolates.dart'
  testCommand: 'fvm dart test test/m12_isolates_test.dart --name m12-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm12-4'
---

El nombre lo dice: un isolate está **aislado**. Este ejercicio convierte esa palabra en un test.

## La demostración

```dart
Future<({List<int> aqui, List<int> alla})> noCompartenMemoria(List<int> original) async {
  final alla = await Isolate.run(() => <int>[...original, 999]);
  return (aqui: original, alla: alla);
}
```

El otro isolate recibió una **copia** de `original`, construyó una lista nueva con un 999 al final y la devolvió. De este lado, `original` sigue teniendo lo mismo que antes.

Y el test lo comprueba dos veces: por contenido y con `identical`, que responde si son el mismo objeto en memoria — la herramienta de D01-L04.

## Qué compra el aislamiento

Con memoria compartida entre hilos, dos que escriben la misma variable producen condiciones de carrera. La solución tradicional son cerrojos, y los cerrojos traen interbloqueos, contención y bugs que solo aparecen bajo carga.

Con isolates ese problema **no existe**. Si nadie puede tocar tu memoria, no hay nada que proteger.

Ese es el intercambio de fondo: pierdes la posibilidad de compartir y ganas no tener que sincronizar. Para el 95 % del código de aplicación, es un buen trato.

## El costo

Copiar no es gratis. Mandar una lista de un millón de elementos a otro isolate paga esa copia dos veces —ida y vuelta—. Si el cálculo es corto, la copia domina el costo, que es exactamente el umbral de la lección anterior.

## Intento · antes de mirar

Predice qué contiene cada lista después de la llamada:

```dart
final original = <int>[1, 2];
final resultado = await noCompartenMemoria(original);
// resultado.aqui  -> ?
// resultado.alla  -> ?
// identical(resultado.aqui, resultado.alla) -> ?
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m12_isolates_test.dart --name m12-4
```

Pega la salida del test que comprueba que son dos objetos distintos.

## Fuente · lee con una pregunta

Abre **Isolates** con una pregunta concreta: ¿qué problemas de concurrencia evita el aislamiento de memoria? Anota el encabezado y si menciona cerrojos.

## Criterio · decide y acepta el costo

Defiende el aislamiento como diseño. Después nombra qué se vuelve imposible: una caché grande compartida entre isolates, por ejemplo, no se puede hacer así.

Elige tu postura y el caso donde te dolería. En la última lección del módulo el bloqueo se vuelve visible en una bitácora.
