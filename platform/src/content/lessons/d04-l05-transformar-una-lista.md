---
id: 'D04-L05'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 4
slug: 'transformar-una-lista-a-mano-y-con-map'
title: 'Escribir map antes de usar map'
summary: 'Transforma una lista con un ciclo explícito, después con map, y comprueba que la entrada no cambió.'
estimatedMinutes: 50
objectives:
  - 'Implementar a mano la transformación que hace map.'
  - 'Comprobar que una función no modifica la colección que recibe.'
  - 'Comparar una versión imperativa y una declarativa del mismo cálculo.'
prerequisites: ['D04-L04']
activities:
  - id: 'predecir-transformar'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe con un ciclo cómo produrías una lista nueva aplicando una transformación, y anota cómo comprobarías que la original no cambió.'
    required: true
    hints:
      - 'Una lista nueva se declara antes del ciclo y se llena dentro.'
      - 'Modificar la entrada sería un efecto lateral que el contrato prohíbe.'
  - id: 'resolver-m05-5'
    kind: 'evidence'
    prompt: 'Implementa transformarTodos primero con un for y una lista nueva. Ejecuta sus pruebas, después reescríbela con map y toList, y pega la salida de la segunda versión.'
    required: true
    hints:
      - 'El test comprueba explícitamente que la lista original no cambió.'
      - 'map devuelve un Iterable perezoso: toList lo materializa.'
  - id: 'sustentar-map'
    kind: 'source'
    prompt: 'En Built-in types, localiza la sección de listas y encuentra qué devuelve map antes de llamar a toList.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca si la página nombra Iterable al describir map.'
      - 'Anota el encabezado y una paráfrasis de la diferencia.'
  - id: 'defender-map'
    kind: 'judgment'
    prompt: 'Elige entre tu ciclo explícito y la versión con map para un proyecto real, y nombra qué caso hace ganar a cada una.'
    required: true
    hints:
      - 'Un ciclo permite acumular más de un resultado a la vez.'
      - 'map comunica que hay exactamente una salida por cada entrada.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantiza map sobre la relación entre entradas y salidas?'
  - 'En un archivo vacío, vuelve a escribir transformarTodos con un ciclo, sin mirar tu solución.'
  - 'Explica en voz alta por qué map devuelve un Iterable y no una List.'
  - 'Escribe una función que transforme una lista y además cuente cuántos elementos cambiaron; decide qué forma te conviene.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-5'
---

Vas a implementar a mano algo que después usarás cien veces por semana. El punto no es que el ciclo sea mejor: es que sepas **qué hace `map` por dentro** antes de confiar en él.

## A mano

```dart
List<int> transformarTodos(List<int> numeros, int Function(int) transformacion) {
  final resultado = <int>[];
  for (final numero in numeros) {
    resultado.add(transformacion(numero));
  }
  return resultado;
}
```

Tres decisiones visibles: se crea una lista nueva, se recorre la entrada sin tocarla, y se agrega **exactamente un** elemento por cada elemento de origen.

## Con map

```dart
return numeros.map(transformacion).toList();
```

Misma semántica, escrita como intención en vez de como procedimiento.

## Por qué hace falta `toList`

`map` no devuelve una `List`: devuelve un `Iterable` **perezoso**. La transformación no se ejecuta al construirlo, sino cuando alguien recorre el resultado — y se vuelve a ejecutar en cada recorrido.

```dart
final vista = numeros.map(transformacion); // todavía no transformó nada
final lista = vista.toList();              // ahora sí, y una sola vez
```

Devolver el `Iterable` sin materializar convierte tu función en una promesa de trabajo futuro, que es un contrato distinto del que declara la firma. Por eso `toList`. Esto se profundiza en D05.

## No tocar la entrada

El contrato prohíbe modificar `numeros`. Es una de las propiedades más valiosas de una función: si no cambia lo que recibe, puedes llamarla sin auditar quién más tiene una referencia a esa lista. El test lo comprueba explícitamente.

## Intento · antes de mirar

Escribe la versión con ciclo de memoria, y anota **cómo comprobarías** desde fuera que la lista original no cambió.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-5
```

Implementa primero con el ciclo. Cuando pase, reescríbela con `map` y `toList`, vuelve a ejecutar y pega la salida de la segunda versión.

## Fuente · lee con una pregunta

Abre **Built-in types**, sección de listas. Pregunta concreta: ¿qué devuelve `map` antes de llamar a `toList`? Anota el encabezado y la palabra que usa la documentación.

## Criterio · decide y acepta el costo

Ambas versiones pasan. Elige.

`map` comunica una garantía que el ciclo no comunica: hay **una salida por cada entrada**, ni más ni menos. El ciclo puede saltarse elementos o agregar dos, y por eso hay que leerlo entero para saber qué hace. A cambio, si mañana necesitas acumular un segundo resultado —cuántos cambiaron, cuál fue el máximo—, el ciclo lo absorbe y `map` hay que reemplazarlo.

En la última lección del módulo vas a recibir una función que no devuelve nada, y medirla.
