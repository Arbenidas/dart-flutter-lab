---
id: 'D01-L04'
trackId: 'dart'
moduleId: 'D01'
kind: 'taller'
order: 3
slug: 'const-y-canonicalizacion'
title: 'const promete más que final'
summary: 'Separa qué queda fijo —la referencia, el objeto o ambos— y comprueba con identical que una constante es el mismo objeto.'
estimatedMinutes: 50
objectives:
  - 'Elegir entre var, final y const según mutabilidad y momento de evaluación.'
  - 'Explicar qué significa que Dart canonicalice un valor constante.'
  - 'Usar identical para distinguir dos objetos iguales de un mismo objeto.'
prerequisites: ['D01-L03']
activities:
  - id: 'predecir-mutabilidad'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice qué ocurre con final lista = <int>[] seguido de lista.add(1), y qué ocurre si la lista fuera const.'
    required: true
    hints:
      - 'Separa dos preguntas: ¿puede cambiar la variable?, ¿puede cambiar el objeto?'
      - 'La inferencia no convierte a var en un tipo dinámico.'
  - id: 'resolver-m02-4'
    kind: 'evidence'
    prompt: 'Declara diasHabiles como const con los cinco días y ejecuta sus pruebas. Pega la salida del test de canonicalización.'
    required: true
    hints:
      - 'El test compara con identical contra otra lista const de los mismos días.'
      - 'Si la declaras final, el valor es igual pero el objeto es otro.'
  - id: 'sustentar-variables'
    kind: 'source'
    prompt: 'En Variables, localiza qué dice la documentación sobre final y const, y en qué momento se conoce el valor de cada uno.'
    required: true
    sourceLabel: 'Variables'
    hints:
      - 'Busca el encabezado Final and const.'
      - 'Fíjate si la página menciona compile-time.'
  - id: 'defender-const'
    kind: 'judgment'
    prompt: 'Decide cuál de estos debe ser const y cuál solo puede ser final: los días hábiles y la hora de inicio de una sesión. Justifica con mutabilidad y momento de evaluación.'
    required: true
    hints:
      - 'Pregunta qué queda fijo: la referencia, el objeto o ambos.'
      - 'Un valor que depende del reloj no se conoce al compilar.'
docRefs:
  - label: 'Variables'
    url: 'https://dart.dev/language/variables'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantiza final y qué garantía adicional ofrece const?'
  - 'En un archivo vacío, vuelve a declarar una lista const de cinco elementos y comprueba con identical que es canonicalizada.'
  - 'Explica en voz alta por qué un campo final que contiene una List no vuelve inmutable esa lista.'
  - 'Toma tres constantes de un proyecto tuyo y decide cuáles pueden ser const y cuáles no; defiende cada caso.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart --name m02-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02-4'
---

`var`, `final` y `const` no son tres formas de escribir lo mismo con distinto nivel de formalidad. Cada una hace una promesa diferente, y la diferencia entre las dos últimas es la que se malinterpreta más.

## Tres declaraciones, tres promesas

```dart
var intentos = 0;
final inicio = DateTime.now();
const diasDeRepaso = 4;
```

- `var` pide al compilador inferir el tipo; la variable puede reasignarse con valores compatibles.
- `final` permite **una sola asignación**, incluso si el valor se obtiene durante la ejecución.
- `const` describe un valor **conocido en compilación**, y profundamente inmutable cuando el objeto también es constante.

`final` no vuelve inmutable al objeto apuntado:

```dart
final etiquetas = <String>[];
etiquetas.add('dart'); // La referencia no cambió; la lista sí.
```

La pregunta correcta no es «¿cuál palabra se ve más profesional?», sino «¿qué cambios debe permitir este modelo?».

## Canonicalización: el mismo objeto, no uno igual

Cuando declaras algo `const`, Dart no crea un objeto nuevo cada vez: reutiliza **el mismo**. Eso se llama canonicalización y se puede comprobar:

```dart
const a = <String>['lunes', 'martes'];
const b = <String>['lunes', 'martes'];
print(identical(a, b)); // true: es el mismo objeto en memoria
```

Con `final` el resultado sería `false`: dos listas distintas con el mismo contenido. `==` no distingue estos dos casos; `identical` sí. Por eso el test de este ejercicio usa `identical` y no `expect(a, b)`.

## Intento · antes de mirar

Predice, por escrito, qué ocurre en cada línea:

```dart
final lista = <int>[];
lista.add(1);        // ¿compila? ¿explota?

const fija = <int>[];
fija.add(1);         // ¿compila? ¿explota?
```

Anota también qué tipo infiere Dart en cada declaración.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart --name m02-4
```

El test de canonicalización es el interesante: pega su salida. Si declaraste `final` en vez de `const`, el contenido será correcto y aun así el test fallará. Ese fallo **es** la lección.

## Fuente · lee con una pregunta

Abre **Variables** y busca el encabezado que trata `final` y `const`. La pregunta concreta: ¿en qué momento se conoce el valor de cada una? Anota la frase que menciona el tiempo de compilación.

## Criterio · decide y acepta el costo

Defiende una decisión concreta: ¿por qué `diasHabiles` debe ser `const` pero la hora de inicio de una sesión solo puede ser `final`? Una buena respuesta menciona **mutabilidad** y **momento de evaluación**, no solo «una no cambia».

En la última lección del módulo vas a comprobar en carne propia qué significa que una lista `const` sea inmutable de verdad.
