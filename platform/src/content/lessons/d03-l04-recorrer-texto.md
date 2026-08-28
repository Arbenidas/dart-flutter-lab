---
id: 'D03-L04'
trackId: 'dart'
moduleId: 'D03'
kind: 'taller'
order: 3
slug: 'recorrer-un-texto-de-dos-formas'
title: 'Recorrer un texto y elegir cómo se lee'
summary: 'Cuenta vocales con un ciclo explícito y después con una expresión, y quédate con la versión que mejor comunica la intención.'
estimatedMinutes: 50
objectives:
  - 'Recorrer los caracteres de un texto con un ciclo for-in.'
  - 'Reescribir un ciclo acumulador como una expresión declarativa.'
  - 'Elegir entre dos implementaciones correctas por criterios de lectura.'
prerequisites: ['D03-L03']
activities:
  - id: 'predecir-vocales'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo contarías vocales sin distinguir mayúsculas ni tildes, y anota qué harías con una cadena vacía.'
    required: true
    hints:
      - 'Normalizar el texto antes de comparar evita multiplicar los casos.'
      - 'Las vocales con tilde también cuentan según el contrato.'
  - id: 'resolver-m04-4'
    kind: 'evidence'
    prompt: 'Implementa contarVocales primero con un for-in, ejecuta sus pruebas, y después reescríbela como una expresión. Pega la salida de la segunda versión.'
    required: true
    hints:
      - 'toLowerCase antes de comparar reduce a la mitad las comprobaciones.'
      - 'Una cadena de vocales y el método contains bastan para la condición.'
  - id: 'sustentar-loops'
    kind: 'source'
    prompt: 'En Loops, encuentra la forma for-in y qué produce al recorrer un texto; después localiza en Built-in types cómo se obtiene la secuencia de caracteres.'
    required: true
    sourceLabel: 'Loops'
    hints:
      - 'Busca el encabezado de for-in loops.'
      - 'Un texto no es directamente una lista de caracteres: hay que producirla.'
  - id: 'defender-legibilidad'
    kind: 'judgment'
    prompt: 'Elige entre tu ciclo explícito y tu versión en una expresión. Defiende la elección con criterios de lectura y depuración, no de longitud.'
    required: true
    hints:
      - 'Una expresión corta puede ocultar dónde poner un punto de interrupción.'
      - 'Un ciclo explícito muestra el acumulador, que a veces es justo lo que importa.'
docRefs:
  - label: 'Loops'
    url: 'https://dart.dev/language/loops'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué produce un for-in al recorrer los caracteres de un texto?'
  - 'En un archivo vacío, vuelve a escribir contarVocales en sus dos formas sin mirar tu solución.'
  - 'Explica en voz alta por qué normalizar el texto antes de comparar reduce el número de casos.'
  - 'Cuenta ahora las consonantes reutilizando la misma estructura y decide qué parte conviene extraer a una función.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart --name m04-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04-4'
---

Este ejercicio parece trivial y contiene la decisión que vas a tomar mil veces: cuándo un ciclo explícito comunica mejor que una expresión, y cuándo es al revés.

## Recorrer caracteres

Un `String` en Dart no es directamente una lista de caracteres. Para recorrerlo hay que producir una secuencia:

```dart
for (final caracter in texto.split('')) {
  // ...
}
```

`split('')` produce una `List<String>` de un carácter cada uno. Existe también `runes`, que trabaja sobre puntos de código y se comporta mejor con caracteres fuera del alfabeto latino. Para este ejercicio ambas sirven; que existan dos ya es información útil.

## Normalizar antes de comparar

El contrato pide ignorar mayúsculas. La opción cómoda es comparar contra diez letras:

```dart
if (c == 'a' || c == 'A' || c == 'e' || c == 'E' /* ... */) { }
```

La opción que escala es normalizar una vez y comparar contra cinco:

```dart
final normalizado = texto.toLowerCase();
```

Reducir el número de casos antes de escribir las condiciones es una técnica general, no un truco de este ejercicio.

## Dos formas de la misma cuenta

```dart
// acumulador explícito
var total = 0;
for (final c in texto.toLowerCase().split('')) {
  if ('aeiouáéíóú'.contains(c)) total++;
}
return total;

// expresión
return texto.toLowerCase().split('').where((c) => 'aeiouáéíóú'.contains(c)).length;
```

Las dos son correctas. La primera muestra el acumulador; la segunda muestra la intención —_filtrar y contar_— sin variables intermedias.

## Intento · antes de mirar

Escribe tu versión y anota qué devuelve con `''`, con `'Dart'` y con `'ÁRBOL'`.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart --name m04-4
```

Implementa primero con el ciclo. Cuando pase, reescríbela como expresión y vuelve a ejecutar. Pega la salida de la segunda versión.

## Fuente · lee con una pregunta

Abre **Loops** y localiza la forma `for-in`. Después salta a **Built-in types** con una segunda pregunta: ¿cómo se obtiene la secuencia de caracteres de un texto? Anota los dos encabezados.

## Criterio · decide y acepta el costo

Ahora la parte que importa: **quédate con una**. Y la razón no puede ser «es más corta».

Si mañana hay que contar vocales _y_ registrar cuáles aparecieron, el acumulador explícito absorbe el cambio sin reescribirse; la expresión hay que rehacerla. Si en cambio la función se queda como está, la expresión dice lo que hace en una línea. Elige, y nombra el escenario donde tu elección envejece peor.

En la última lección del módulo el ciclo deja de contar y empieza a **construir**.
