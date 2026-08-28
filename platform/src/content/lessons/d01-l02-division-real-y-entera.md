---
id: 'D01-L02'
trackId: 'dart'
moduleId: 'D01'
kind: 'taller'
order: 1
slug: 'division-real-y-division-entera'
title: 'Dividir no siempre da lo que esperas'
summary: 'Compara la división real con la división entera y descubre por qué el tipo de retorno de una conversión no es un detalle.'
estimatedMinutes: 45
objectives:
  - 'Distinguir el operador / del operador ~/ por su resultado y por su tipo.'
  - 'Justificar por qué una conversión de temperatura devuelve double y no num.'
  - 'Leer un test que comprueba el tipo del resultado, no solo su valor.'
prerequisites: ['D01-L01']
activities:
  - id: 'predecir-division'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe qué devuelven 7 / 2, 7 ~/ 2 y 6 / 3, y de qué tipo es cada resultado.'
    required: true
    hints:
      - 'Uno de los tres resultados sorprende a casi todo el mundo.'
      - 'Pregúntate qué tipo debe devolver un operador que a veces da decimales.'
  - id: 'resolver-m02-2'
    kind: 'evidence'
    prompt: 'Implementa aCelsius aplicando (f - 32) * 5 / 9, ejecuta sus pruebas y pega la salida del test que comprueba el tipo del resultado.'
    required: true
    hints:
      - 'La fórmula ya está en la documentación de la función.'
      - 'El test «devuelve double, no int» comprueba el tipo, no el valor.'
  - id: 'sustentar-operadores'
    kind: 'source'
    prompt: 'En Built-in types, localiza la sección de números y encuentra qué devuelve / frente a ~/. Registra el encabezado exacto.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca la palabra division dentro de la página.'
      - 'Fíjate si la página nombra el tipo del resultado además del valor.'
  - id: 'defender-tipo-retorno'
    kind: 'judgment'
    prompt: 'Decide si aCelsius debería declarar double o num como tipo de retorno y qué le cuesta a quien la llame cada opción.'
    required: true
    hints:
      - 'num obliga a quien llama a comprobar antes de usar el resultado.'
      - 'Un tipo más ancho no es más flexible: traslada trabajo al consumidor.'
docRefs:
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Operators'
    url: 'https://dart.dev/language/operators'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre / y ~/ en Dart, en valor y en tipo?'
  - 'En un archivo vacío, vuelve a escribir aCelsius sin mirar tu solución.'
  - 'Explica en voz alta por qué 6 / 3 no devuelve un int en Dart.'
  - 'Escribe la conversión inversa, de Celsius a Fahrenheit, y decide su tipo de retorno antes del cuerpo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart --name m02-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02-2'
---

La aritmética parece el terreno más seguro de un lenguaje, y es donde aparecen las primeras sorpresas. En Dart hay **dos divisiones**, y la que se escribe con la barra habitual casi nunca devuelve lo que la intuición espera.

## Dos operadores, dos contratos

```dart
print(7 / 2);   // 3.5   -> double
print(7 ~/ 2);  // 3     -> int
print(6 / 3);   // 2.0   -> double, no 2
```

`/` es la **división real**: siempre devuelve `double`, incluso cuando el resultado es exacto. `~/` es la **división entera truncada**: descarta la parte decimal y devuelve `int`.

`6 / 3` dando `2.0` es la línea que conviene recordar. El tipo de retorno de un operador es fijo; no depende de los valores concretos que le toquen en una ejecución.

## El tipo también es parte del contrato

La función de esta lección convierte grados Fahrenheit a Celsius:

```dart
double aCelsius(double fahrenheit) { ... }
```

Podría haberse declarado `num`. Sería técnicamente correcto y peor: quien la llame recibiría un valor que _podría_ ser entero o decimal, y tendría que comprobarlo antes de usarlo. Declarar `double` traslada la certeza al consumidor. Un tipo más ancho no es más flexible: es más trabajo para todos los que vengan después.

Por eso el test `devuelve double, no int` no es redundante. Comprueba el contrato, no el cálculo.

## Intento · antes de mirar

Antes de tocar el archivo, escribe qué devuelven `7 / 2`, `7 ~/ 2` y `6 / 3`, **con su tipo**. Después predice el resultado de `aCelsius(32)` y `aCelsius(212)`.

## Evidencia · ejecuta y compara

Implementa la función y ejecuta solo sus pruebas:

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart --name m02-2
```

Copia la salida exacta. Si el test de tipo falla mientras los de valor pasan, ya sabes que el problema no es la fórmula: es qué operador usaste.

## Fuente · lee con una pregunta

Abre **Built-in types** y ve directamente a la sección de números. La pregunta es concreta: ¿qué tipo devuelve cada división? Anota el encabezado y la frase que lo responde. No leas el resto de la página.

## Criterio · decide y acepta el costo

Defiende el tipo de retorno. Si la función devolviera `num`, ¿qué tendría que escribir quien la use antes de mostrar el resultado con un decimal? Nombra la alternativa que descartas y el costo que aceptas.

En la próxima lección el problema deja de ser el tipo del resultado y pasa a ser la **representación**: el dinero no cabe en un `double`.
