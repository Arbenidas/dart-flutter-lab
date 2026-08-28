---
id: 'D00-L02'
trackId: 'dart'
moduleId: 'D00'
kind: 'taller'
order: 1
slug: 'leer-un-error-del-analizador'
title: 'Leer el error antes de arreglarlo'
summary: 'Rompe tu programa a propósito, aprende qué cuatro datos trae un diagnóstico del analizador y escribe un archivo nuevo de memoria.'
estimatedMinutes: 40
objectives:
  - 'Provocar un error de sintaxis y localizar archivo, línea, columna y descripción en el diagnóstico.'
  - 'Distinguir el analizador estático de la ejecución del programa.'
  - 'Crear y ejecutar un archivo Dart propio sin copiar el original.'
prerequisites: ['D00-L01']
activities:
  - id: 'predecir-mensaje'
    kind: 'attempt'
    prompt: 'Antes de tocar nada, escribe qué crees que dirá la herramienta si borras un punto y coma, y si eso lo detectará el analizador o la ejecución.'
    required: true
    hints:
      - 'Un punto y coma marca el final de una instrucción.'
      - '¿Hace falta ejecutar el programa para saber que la sintaxis está rota?'
  - id: 'provocar-el-fallo'
    kind: 'evidence'
    prompt: 'Quita el punto y coma de la segunda llamada a print, ejecuta fvm dart analyze y pega la línea del diagnóstico. Después restaura el punto y coma y vuelve a analizar hasta que quede limpio.'
    required: true
    hints:
      - 'El analizador suele indicar archivo, línea, columna y una descripción.'
      - 'No necesitas entender cada palabra: localiza primero dónde ocurrió.'
  - id: 'rastrear-analizador'
    kind: 'source'
    prompt: 'En la documentación de dart run, localiza qué hace la herramienta antes de ejecutar y explica por qué un error de sintaxis impide llegar a la salida.'
    required: true
    sourceLabel: 'dart run'
    hints:
      - 'Busca el encabezado que habla de compilación o de errores.'
      - 'Compara lo que dice la página con lo que viste en tu terminal.'
  - id: 'escribir-de-memoria'
    kind: 'judgment'
    prompt: 'Crea bin/m01_practica.dart, escribe de memoria un main con un saludo propio y ejecútalo. Después decide qué conviene más para practicar: editar el archivo original o crear uno nuevo, y qué costo tiene cada opción.'
    required: true
    hints:
      - 'Este archivo nuevo no viene en el ZIP: lo creas tú dentro de la carpeta bin.'
      - 'Necesitas la misma estructura; solo cambia el texto entre comillas.'
docRefs:
  - label: 'dart run'
    url: 'https://dart.dev/tools/dart-run'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'The main() function'
    url: 'https://dart.dev/language/functions#the-main-function'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué cuatro datos buscas primero en un mensaje del analizador?'
  - 'En un archivo vacío, vuelve a escribir un main que compile a la primera, sin mirar ningún ejemplo.'
  - 'Explica en voz alta la diferencia entre lo que detecta fvm dart analyze y lo que solo aparece al ejecutar.'
  - 'Provoca un error distinto —una comilla sin cerrar— y predice el diagnóstico antes de leerlo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'bin/m01_hola.dart'
  testCommand: 'fvm dart run bin/m01_hola.dart'
  analyzeCommand: 'fvm dart analyze'
  revealReference: true
---

Un error no es un castigo: es la herramienta contándote qué esperaba encontrar. Aprender a leerlo es la habilidad que más te va a ahorrar tiempo en los próximos meses, y se practica provocando errores a propósito mientras son baratos.

## Dos momentos distintos

Dart revisa tu código **antes** de ejecutarlo. Esa revisión se llama análisis estático y la pide este comando:

```bash
fvm dart analyze
```

`analyze` no corre tu programa: solo lee el código y busca contradicciones. Un punto y coma faltante, un nombre mal escrito o un tipo incompatible aparecen aquí. Otros problemas —una división por cero, un archivo que no existe— solo se manifiestan al ejecutar.

Saber en cuál de los dos momentos falló algo ya reduce a la mitad el lugar donde buscar.

## Anatomía de un diagnóstico

Un mensaje del analizador trae siempre cuatro datos:

| Dato        | Para qué sirve                            |
| ----------- | ----------------------------------------- |
| archivo     | en qué archivo mirar                      |
| línea       | dónde empezar a leer                      |
| columna     | qué símbolo exacto disparó el problema    |
| descripción | qué esperaba la herramienta y no encontró |

La descripción suele ser lo último que se entiende y lo primero que la gente intenta leer. Empieza por los tres primeros.

## Intento · antes de mirar

Antes de romper nada, escribe tu predicción: si borras el `;` de la segunda línea, ¿qué dirá la herramienta y quién lo detectará, `analyze` o la ejecución? Anótalo. Vas a compararlo en un minuto.

## Evidencia · provoca el fallo

Quita temporalmente el `;` de la segunda llamada a `print` y guarda. Ahora consulta el analizador:

```bash
fvm dart analyze
```

No intentes comprender todo el mensaje a la vez. Localiza los cuatro datos y pega la línea del diagnóstico. Después restaura el `;`, guarda y vuelve a ejecutar `fvm dart analyze` hasta que el error desaparezca.

Completa estas frases:

1. «Yo cambié…»
2. «El analizador señaló…»
3. «La regla que ahora entiendo es…»

## Fuente · lee con una pregunta

Vuelve a **dart run** con una pregunta nueva: ¿qué hace la herramienta con tu archivo antes de ejecutarlo? Busca el encabezado que menciona compilación o errores y conéctalo con lo que acabas de ver: un programa con sintaxis rota nunca llega a imprimir nada.

## Criterio · decide y acepta el costo

Ahora crearás un archivo nuevo de forma intencional; no debes buscarlo en el ZIP:

1. En el explorador de VS Code, haz clic derecho sobre `dart_lab/bin`.
2. Crea `m01_practica.dart`.
3. Escribe de memoria un `main` con una llamada a `print` y un saludo propio.
4. Ejecútalo desde `dart_lab`:

```bash
fvm dart run bin/m01_practica.dart
```

Después decide: para experimentar, ¿conviene editar `m01_hola.dart` o crear archivos aparte? Nombra la opción que descartas y su costo — uno pierde el original, el otro llena la carpeta de archivos sueltos.

## Regla sobre las pistas y la IA

Una pista útil reduce el espacio del problema sin hacer el trabajo central. Puede pedirte que leas una línea, que localices un símbolo o que consultes un encabezado. Usa una respuesta completa solo después de intentar, ejecutar, leer el error y escribir lo que ya descartaste.
