---
id: 'D04-L04'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 3
slug: 'aplicacion-parcial'
title: 'Fijar un argumento y devolver el resto'
summary: 'Devuelve una función especializada a partir de un parámetro, y reconoce el patrón en las APIs que ya usas.'
estimatedMinutes: 40
objectives:
  - 'Devolver una función que captura un argumento de la función externa.'
  - 'Nombrar el patrón de aplicación parcial y reconocerlo en código ajeno.'
  - 'Decidir cuándo especializar una función y cuándo pasar el argumento cada vez.'
prerequisites: ['D04-L03']
activities:
  - id: 'predecir-multiplicador'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe la firma y el cuerpo de multiplicadorPor, y predice qué devuelve el resultado de aplicarlo con 2 sobre 21.'
    required: true
    hints:
      - 'El tipo de retorno ya te dice qué forma tiene el valor devuelto.'
      - 'El factor viene de la función externa; el otro número, de la interna.'
  - id: 'resolver-m05-4'
    kind: 'evidence'
    prompt: 'Implementa multiplicadorPor, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - 'Es una closure: la función interna captura el factor.'
      - 'Puedes escribirla en una sola expresión con flecha.'
  - id: 'sustentar-return-function'
    kind: 'source'
    prompt: 'En Functions, encuentra cómo se declara una función que devuelve otra función y registra el encabezado.'
    required: true
    sourceLabel: 'Functions'
    hints:
      - 'El tipo de retorno se escribe igual que un tipo de parámetro función.'
      - 'Busca ejemplos que combinen closures y retorno.'
  - id: 'defender-especializar'
    kind: 'judgment'
    prompt: 'Decide cuándo conviene crear un multiplicador especializado y cuándo pasar el factor en cada llamada; nombra el costo de cada opción.'
    required: true
    hints:
      - 'Especializar tiene sentido si el factor se repite en muchas llamadas seguidas.'
      - 'Una función especializada más es un nombre más que mantener.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué captura la función devuelta por multiplicadorPor?'
  - 'En un archivo vacío, vuelve a escribir multiplicadorPor sin mirar tu solución.'
  - 'Explica en voz alta qué es la aplicación parcial y dónde la has visto sin saber su nombre.'
  - 'Escribe una función que reciba un prefijo y devuelva un formateador de mensajes; úsala dos veces con prefijos distintos.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-4'
---

Esta lección es corta porque el mecanismo ya lo sabes: es una closure. Lo nuevo es reconocer **el patrón** y saber cómo se llama.

## Aplicación parcial

Una función necesita dos datos. Le das uno ahora y recibes una función que espera el otro:

```dart
int Function(int) multiplicadorPor(int factor) {
  return (numero) => numero * factor;
}

final doble = multiplicadorPor(2);
final triple = multiplicadorPor(3);

doble(21);  // 42
triple(14); // 42
```

`factor` viene de la función externa y queda capturado. `numero` llega en cada llamada. `doble` y `triple` son dos funciones independientes creadas desde el mismo molde.

Se llama **aplicación parcial**: aplicaste parte de los argumentos y obtuviste una función más especializada.

## Dónde lo has visto ya

Este patrón está en todas partes en cuanto sabes nombrarlo:

- Un `builder` que captura el tema o el idioma y devuelve un widget.
- Un formateador creado con una moneda fija y reutilizado en toda una pantalla.
- Un cliente HTTP configurado con una URL base que solo espera la ruta.

Nombrarlo cambia cómo lees código ajeno.

## Intento · antes de mirar

Escribe la firma y el cuerpo completos antes de abrir el archivo. Después predice qué imprime:

```dart
final doble = multiplicadorPor(2);
final triple = multiplicadorPor(3);
print(doble(21) + triple(0));
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-4
```

Pega la salida. Este ejercicio también comprueba la estructura, no solo el resultado.

## Fuente · lee con una pregunta

Vuelve a **Functions** con una pregunta nueva: ¿cómo se declara una función cuyo tipo de retorno es otra función? Anota el encabezado; es la misma sintaxis que ya usaste para un parámetro, en otra posición.

## Criterio · decide y acepta el costo

Defiende cuándo conviene: si multiplicas por dos en una línea suelta, `n * 2` gana sin discusión. Si el mismo factor aparece en veinte llamadas de un módulo, `doble` documenta la intención y concentra el cambio en un lugar.

Nombra el costo: cada función especializada es un nombre más que alguien tendrá que buscar. En la próxima lección vas a implementar a mano algo que ya usas todos los días sin saber cómo funciona por dentro.
