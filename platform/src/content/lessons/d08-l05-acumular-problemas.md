---
id: 'D08-L05'
trackId: 'dart'
moduleId: 'D08'
kind: 'taller'
order: 4
slug: 'validar-acumulando-problemas'
title: 'Devolver todos los problemas, no el primero'
summary: 'Usa el tipo sellado para una validación real que junta todos los motivos en vez de detenerse en el primero.'
estimatedMinutes: 50
objectives:
  - 'Acumular varios problemas de validación en un solo resultado.'
  - 'Justificar cuándo detenerse en el primer error y cuándo seguir.'
  - 'Conectar el modelo con la experiencia de quien corrige el dato.'
prerequisites: ['D08-L04']
activities:
  - id: 'predecir-acumulacion'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué debería devolver validarUsuario para un texto de 21 caracteres que además contiene un espacio, y por qué.'
    required: true
    hints:
      - 'Detenerse en el primer problema obliga a corregir de a uno.'
      - 'Acumular exige que las validaciones sean independientes entre sí.'
  - id: 'resolver-m09-5'
    kind: 'evidence'
    prompt: 'Implementa validarUsuario acumulando los problemas. Ejecuta sus pruebas y pega la salida del caso que rompe dos reglas a la vez.'
    required: true
    hints:
      - 'Junta los mensajes en una lista y decide al final.'
      - 'Normaliza el texto antes de validar, y devuelve el normalizado si es válido.'
  - id: 'sustentar-patterns-clases'
    kind: 'source'
    prompt: 'En Patterns, encuentra cómo se desestructura un objeto dentro de un switch y qué sintaxis usa para leer un campo.'
    required: true
    sourceLabel: 'Patterns'
    hints:
      - 'Busca object patterns.'
      - 'Anota la sintaxis exacta con el nombre del campo.'
  - id: 'defender-acumular'
    kind: 'judgment'
    prompt: 'Decide si conviene acumular todos los problemas o detenerse en el primero, y nombra un caso donde tu elección sería la equivocada.'
    required: true
    hints:
      - 'Acumular exige que ninguna validación dependa del resultado de otra.'
      - 'Un formulario largo y una petición de API tienen expectativas distintas.'
docRefs:
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué gana quien corrige un dato cuando la validación acumula todos los problemas?'
  - 'En un archivo vacío, vuelve a escribir validarUsuario con sus tres reglas, sin mirar tu solución.'
  - 'Explica en voz alta cuándo acumular validaciones no es posible.'
  - 'Modela Resultado para una validación de contraseña con cuatro reglas y decide cuáles pueden comprobarse en paralelo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m09_modelado.dart'
  testCommand: 'fvm dart test test/m09_modelado_test.dart --name m09-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm09-5'
  revealReference: true
---

El tipo sellado de la lección anterior existe para algo. Este ejercicio es ese algo.

## Detenerse o acumular

```dart
// se detiene en el primero
if (normalizado.isEmpty) return Invalido(['vacío']);
if (normalizado.length > 20) return Invalido(['muy largo']);
```

Funciona, y produce una experiencia conocida: corriges un campo, envías, aparece el siguiente problema, corriges, envías. Cuatro reglas rotas son cuatro viajes.

```dart
// acumula
final problemas = <String>[];
if (normalizado.isEmpty) problemas.add('El usuario no puede estar vacío.');
if (normalizado.length > 20) problemas.add('El usuario debe tener 20 caracteres o menos.');
if (normalizado.contains(' ')) problemas.add('El usuario no puede contener espacios.');

return problemas.isEmpty ? Valido<String>(normalizado) : Invalido<String>(problemas);
```

Un viaje. Y la razón por la que `Invalido` lleva una **lista** de mensajes y no uno solo se vuelve evidente aquí.

## Cuándo no se puede acumular

Acumular exige que las validaciones sean **independientes**. Si la segunda solo tiene sentido cuando la primera pasó —comprobar el formato de una fecha después de saber que es una fecha—, no hay más remedio que encadenar.

La regla práctica: acumula lo que se puede comprobar sobre el dato crudo; encadena lo que depende de una conversión previa.

## Normalizar antes, devolver lo normalizado

```dart
final normalizado = entrada.trim();
// ...
return Valido<String>(normalizado);
```

El `Valido` lleva el texto **ya limpio**. Devolver la entrada original obligaría a cada consumidor a normalizar otra vez — y a acordarse. Es el mismo argumento de D05-L02: la normalización va en un solo lugar.

## Intento · antes de mirar

Escribe qué debería devolver la función para estas entradas:

| Entrada                      | Resultado |
| ---------------------------- | --------- |
| `'  ana  '`                  | ?         |
| `'   '`                      | ?         |
| 21 caracteres con un espacio | ?         |

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m09_modelado_test.dart --name m09-5
```

Pega la salida del caso que rompe dos reglas a la vez. Si tu implementación se detiene en la primera, ese test lo dice con un número: espera dos mensajes.

## Fuente · lee con una pregunta

Abre **Patterns** y busca _object patterns_. Pregunta concreta: ¿cuál es la sintaxis para leer un campo de un objeto dentro de un `switch`? Anótala; la vas a usar cada vez que consumas un tipo sellado.

## Criterio · decide y acepta el costo

Defiende acumular. Después nombra el caso donde sería la elección equivocada: una API que valida un cuerpo enorme puede preferir detenerse en el primer error por costo, y una validación que depende de una conversión previa no puede acumular aunque quiera.

Cierra el módulo:

```bash
fvm dart analyze
```

En D09 los fallos dejan de ser un valor devuelto y empiezan a **subir por la pila**.
