---
id: 'D04-L02'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 1
slug: 'parametros-con-nombre-y-por-defecto'
title: 'Un bool sin nombre no dice nada'
summary: 'Usa parámetros con nombre y valores por defecto para que la llamada se lea sin abrir la función.'
estimatedMinutes: 45
objectives:
  - 'Declarar parámetros con nombre y valores por defecto.'
  - 'Justificar cuándo un parámetro debe llevar nombre obligatorio.'
  - 'Evaluar una llamada por su legibilidad en el punto de uso.'
prerequisites: ['D04-L01']
activities:
  - id: 'predecir-etiqueta'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe la firma de etiqueta con sus tres comportamientos y predice el resultado de etiqueta con prefijo y mayúsculas a la vez.'
    required: true
    hints:
      - 'El contrato dice que el prefijo NO se pone en mayúsculas.'
      - 'El orden en que apliques las dos transformaciones decide el resultado.'
  - id: 'resolver-m05-2'
    kind: 'evidence'
    prompt: 'Implementa etiqueta con parámetros con nombre y valores por defecto, ejecuta sus pruebas y pega la salida del caso que combina prefijo y mayúsculas.'
    required: true
    hints:
      - 'Los parámetros con nombre van entre llaves en la firma.'
      - 'Aplica las mayúsculas al texto antes de anteponer el prefijo.'
  - id: 'sustentar-named'
    kind: 'source'
    prompt: 'En Functions, localiza la sección de parámetros con nombre y encuentra cómo se declara un valor por defecto y cómo se vuelve obligatorio uno.'
    required: true
    sourceLabel: 'Functions'
    hints:
      - 'Busca named parameters dentro de la página.'
      - 'Fíjate en la palabra required.'
  - id: 'defender-nombre'
    kind: 'judgment'
    prompt: 'Compara etiqueta con un bool posicional frente a uno con nombre en el punto de llamada. Decide una regla propia y nombra su costo.'
    required: true
    hints:
      - 'Lee en voz alta etiqueta con true como segundo argumento: ¿qué significa true ahí?'
      - 'Los nombres alargan la llamada; el costo es real aunque sea pequeño.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Variables'
    url: 'https://dart.dev/language/variables'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué un parámetro bool suele ser más claro cuando es nombrado?'
  - 'En un archivo vacío, vuelve a escribir etiqueta con sus dos parámetros con nombre, sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre un parámetro con nombre opcional y uno con nombre obligatorio.'
  - 'Toma una función tuya con cuatro parámetros posicionales y reescribe su firma; justifica cuáles pasan a llevar nombre.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-2'
---

Una firma no se juzga donde se escribe: se juzga donde se **llama**. Esta lección es sobre eso.

## El problema

```dart
etiqueta('hola', true, '>> ');
```

¿Qué significa `true` ahí? Para saberlo hay que abrir la función. Multiplicado por cada llamada del proyecto, eso es un impuesto permanente sobre la lectura.

## Parámetros con nombre

```dart
String etiqueta(String texto, {bool mayusculas = false, String prefijo = ''}) { ... }

etiqueta('hola');                                  // 'hola'
etiqueta('hola', mayusculas: true);                // 'HOLA'
etiqueta('hola', prefijo: '>> ');                  // '>> hola'
etiqueta('hola', prefijo: '>> ', mayusculas: true); // '>> HOLA'
```

Las llaves declaran parámetros con nombre. Un valor por defecto los vuelve opcionales; `required` los vuelve obligatorios sin perder el nombre. Fíjate además en que el orden en la llamada deja de importar: son nombres, no posiciones.

La regla práctica: **si una función tiene más de dos parámetros, o si alguno es un `bool`, van con nombre**. Flutter la aplica en todas partes; por eso los constructores de widgets se leen tan bien.

## El orden sí importa dentro

El contrato dice que el prefijo **no** se pone en mayúsculas. Eso fija el orden de las operaciones: primero transformar el texto, después anteponer el prefijo. Invertirlo produce `'>> HOLA'` contra `'>> HOLA'`… salvo que el prefijo tenga letras.

## Intento · antes de mirar

Escribe la firma completa y predice las cuatro llamadas del ejemplo. Presta atención a la última.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-2
```

Pega la salida del caso que combina prefijo y mayúsculas. Es el único que distingue el orden correcto del invertido.

## Fuente · lee con una pregunta

Abre **Functions** y busca _named parameters_. Dos preguntas: ¿cómo se declara un valor por defecto?, ¿cómo se vuelve obligatorio un parámetro con nombre? Anota el encabezado y la palabra clave.

## Criterio · decide y acepta el costo

Escribe tu propia regla sobre cuándo un parámetro lleva nombre, y defiéndela. Después nombra el costo: las llamadas se vuelven más largas, y en funciones de un solo argumento evidente el nombre solo agrega ruido.

En la próxima lección las funciones dejan de recibir datos y empiezan a **recordarlos**.
