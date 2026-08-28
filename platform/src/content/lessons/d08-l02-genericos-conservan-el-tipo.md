---
id: 'D08-L02'
trackId: 'dart'
moduleId: 'D08'
kind: 'taller'
order: 1
slug: 'genericos-que-conservan-el-tipo'
title: 'Un genérico conserva lo que Object pierde'
summary: 'Escribe una función que funciona con cualquier tipo sin obligar a quien la llama a convertir el resultado.'
estimatedMinutes: 45
objectives:
  - 'Declarar una función genérica con un parámetro de tipo.'
  - 'Explicar qué pierde quien recibe un Object en lugar de un T.'
  - 'Recorrer un Iterable sin materializarlo.'
prerequisites: ['D08-L01']
activities:
  - id: 'predecir-object'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe la firma de una función que devuelva el primer elemento o null, primero con Object? y después con T?, y anota qué tiene que escribir el llamador en cada caso.'
    required: true
    hints:
      - 'Con Object? el llamador necesita un as o un is para usar el valor.'
      - 'Con T? el compilador ya sabe qué recibió.'
  - id: 'resolver-m09-2'
    kind: 'evidence'
    prompt: 'Implementa primeroONull sin materializar la colección. Ejecuta sus pruebas y pega la salida del test que comprueba el tipo del resultado.'
    required: true
    hints:
      - 'Un Iterable ofrece iterator con moveNext y current.'
      - 'Llamar a toList primero funcionaría y recorrería de más.'
  - id: 'sustentar-generics'
    kind: 'source'
    prompt: 'En Generics, encuentra por qué la documentación recomienda tipos genéricos y qué problema evitan frente a colecciones de Object.'
    required: true
    sourceLabel: 'Generics'
    hints:
      - 'Busca la sección sobre por qué usar genéricos.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-generico'
    kind: 'judgment'
    prompt: 'Decide si vale la pena hacer genérica una función que hoy solo se usa con String, y nombra el costo de generalizar antes de tiempo.'
    required: true
    hints:
      - 'Un genérico no cuesta nada en ejecución pero sí en legibilidad.'
      - 'Generalizar sin un segundo caso de uso suele producir la abstracción equivocada.'
docRefs:
  - label: 'Generics'
    url: 'https://dart.dev/language/generics'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Iterable class'
    url: 'https://api.dart.dev/stable/dart-core/Iterable-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué información conserva T en un tipo o una función genérica?'
  - 'En un archivo vacío, vuelve a escribir primeroONull sin mirar tu solución.'
  - 'Explica en voz alta qué tiene que escribir quien recibe un Object? y no un T?.'
  - 'Escribe una función genérica que devuelva el último elemento o null y decide si merece existir.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m09_modelado.dart'
  testCommand: 'fvm dart test test/m09_modelado_test.dart --name m09-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm09-2'
---

Un genérico no es una función que «acepta cualquier cosa». Es una función que **conserva** el tipo que le dieron.

## Lo que se pierde con Object

```dart
Object? primeroONull(Iterable<Object?> elementos) { ... }

final nombre = primeroONull(<String>['ana']); // Object?
print(nombre.length);                          // no compila
print((nombre as String).length);              // compila y puede explotar
```

La función funcionó. El problema es lo que le dejó a quien la llamó: un valor sin tipo útil y la obligación de convertirlo con un `as` que nadie comprueba.

## Lo que conserva T

```dart
T? primeroONull<T>(Iterable<T> elementos) { ... }

final nombre = primeroONull(<String>['ana']); // String?
print(nombre?.length);                         // compila, y es seguro
```

`T` es una variable de tipo: se resuelve en cada llamada. El compilador conecta la entrada con la salida, así que quien pasa `List<String>` recibe `String?` sin escribir nada extra.

Y no cuesta nada en ejecución: es información que existe al compilar.

## Sin materializar

```dart
final iterador = elementos.iterator;
return iterador.moveNext() ? iterador.current : null;
```

`moveNext()` avanza una posición y devuelve si había algo. Sobre una colección de un millón de elementos, esto toca **uno**. Llamar a `toList()` primero también funcionaría y recorrería el millón entero — la misma lección de pereza de D05-L05.

## Intento · antes de mirar

Escribe las dos firmas —con `Object?` y con `T?`— y, para cada una, la línea que tendría que escribir quien la llama para usar el resultado como texto.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m09_modelado_test.dart --name m09-2
```

Pega la salida del test que comprueba el tipo del resultado. Ese test asigna a un `String?` explícito: si tu firma perdiera el tipo, no compilaría.

## Fuente · lee con una pregunta

Abre **Generics** con una pregunta concreta: ¿qué problema evitan los genéricos frente a colecciones de `Object`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende hacer genérica una función que hoy solo usas con `String`. A favor: no cuesta nada y evita reescribirla. En contra: `<T>` en la firma es una barrera de lectura, y generalizar sin un segundo caso de uso real suele producir la abstracción equivocada.

Elige y nombra tu criterio. En la próxima lección el tipo de retorno deja de ser un valor y pasa a ser **varios a la vez**.
