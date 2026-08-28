---
id: 'D11-L03'
trackId: 'dart'
moduleId: 'D11'
kind: 'taller'
order: 2
slug: 'un-umbral-que-se-mide'
title: 'Un umbral es una medición, no una corazonada'
summary: 'Escribe una estrategia que decide por tamaño y define qué medirías antes de fijar el número.'
estimatedMinutes: 50
objectives:
  - 'Implementar una estrategia que elige entre dos caminos según un umbral.'
  - 'Explicar por qué un umbral inventado es peor que no tener ninguno.'
  - 'Definir qué habría que medir para justificar un número.'
prerequisites: ['D11-L02']
activities:
  - id: 'predecir-umbral'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería hacer la función por debajo y por encima del umbral, y de dónde debería salir ese número.'
    required: true
    hints:
      - 'Por debajo del umbral el traslado cuesta más que el cálculo.'
      - 'Un número que nadie midió es tan arbitrario como no tener ninguno.'
  - id: 'resolver-m12-3'
    kind: 'evidence'
    prompt: 'Implementa sumaDeCuadradosAdaptativa con su umbral parametrizable. Ejecuta sus pruebas y pega la salida de los dos casos.'
    required: true
    hints:
      - 'El umbral debe ser un parámetro con valor por defecto, no una constante escondida.'
      - 'Los dos caminos deben producir el mismo resultado.'
  - id: 'sustentar-rendimiento'
    kind: 'source'
    prompt: 'En Isolates, encuentra qué dice la documentación sobre cuándo conviene usar un isolate y qué costo menciona.'
    required: true
    sourceLabel: 'Isolates'
    hints:
      - 'Busca la parte que compara el costo del traslado con el del cálculo.'
      - 'Anota el encabezado y la recomendación.'
  - id: 'defender-umbral-parametrizable'
    kind: 'judgment'
    prompt: 'Decide si el umbral debe ser un parámetro o una constante interna, y nombra qué gana cada opción para las pruebas y para el ajuste.'
    required: true
    hints:
      - 'Un parámetro permite probar los dos caminos sin cálculos enormes.'
      - 'Una constante evita que cada llamada tenga que decidir un número.'
docRefs:
  - label: 'Isolates'
    url: 'https://dart.dev/language/isolates'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo elegirías Isolate.run y cuándo resolver en el isolate actual?'
  - 'En un archivo vacío, vuelve a escribir sumaDeCuadradosAdaptativa sin mirar tu solución.'
  - 'Explica en voz alta por qué un umbral inventado puede ser peor que no tener ninguno.'
  - 'Define las tres métricas que necesitarías antes de fijar el umbral de tu propio proyecto.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m12_isolates.dart'
  testCommand: 'fvm dart test test/m12_isolates_test.dart --name m12-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm12-3'
---

Mover todo a un isolate es tan malo como no mover nada. La decisión depende del tamaño, y el tamaño hay que medirlo.

## La estrategia

```dart
Future<int> sumaDeCuadradosAdaptativa(int n, {int umbral = 100000}) {
  return n < umbral
      ? Future<int>.value(sumaDeCuadrados(n))
      : sumaDeCuadradosEnIsolate(n);
}
```

Dos caminos, un mismo contrato. Quien la llame recibe siempre un `Future<int>` y no sabe —ni le importa— cuál se tomó.

`Future.value` envuelve un resultado ya calculado. No espera nada: solo iguala la firma.

## El umbral es un parámetro

`{int umbral = 100000}` tiene dos ventajas sobre una constante escondida:

1. **Se puede probar.** El test usa `umbral: 1000` y comprueba los dos caminos sin tener que calcular cien mil cuadrados.
2. **Se puede ajustar.** Un dispositivo lento y un servidor no tienen el mismo punto de equilibrio.

## De dónde sale el número

`100000` es un valor por defecto razonable **y no está medido**. Para justificarlo harían falta tres cosas:

1. Un entorno controlado, sin otros procesos compitiendo.
2. Repeticiones, con descarte de los valores extremos.
3. Medir el **coste total** —copia de ida, cálculo, copia de vuelta— y no solo el cálculo.

Nada de eso lo tienes todavía. Eso es D14, y hasta entonces cualquier número es una hipótesis, no un dato. Lo honesto es escribirlo así en el código.

## Intento · antes de mirar

Decide qué debería hacer la función con `n = 10` y con `n = 1000000`, y anota qué medirías para elegir el punto de corte.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m12_isolates_test.dart --name m12-3
```

Pega la salida de los dos casos. Fíjate en que los tests comprueban **el mismo resultado por los dos caminos**: eso es lo que hace que la estrategia sea segura de cambiar.

## Fuente · lee con una pregunta

Abre **Isolates** con una pregunta concreta: ¿qué costo menciona la documentación al usar un isolate? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende el umbral como parámetro. Una constante interna evita que cada llamada tenga que pensar un número, y hace imposible probar el camino corto sin trabajo real.

Elige y nombra el costo. En la próxima lección se comprueba, con un test, que los dos isolates de verdad no comparten nada.
