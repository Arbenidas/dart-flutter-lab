---
id: 'D00-L01'
trackId: 'dart'
moduleId: 'D00'
order: 0
slug: 'como-estudiar-programacion'
title: 'Tu primer programa en Dart'
summary: 'Encuentra el archivo de práctica, reconoce la sintaxis mínima de Dart y usa PENSAR para ejecutar, observar y explicar tu primer programa.'
estimatedMinutes: 55
objectives:
  - 'Encontrar el starter y abrir dart_lab/bin/m01_hola.dart sin adivinar rutas.'
  - 'Reconocer main, llaves, print, texto entre comillas y punto y coma.'
  - 'Ejecutar un archivo Dart y consultar el analizador desde la terminal.'
  - 'Aplicar las seis etapas de PENSAR en una sesión corta.'
prerequisites: []
activities:
  - id: 'predecir-salida'
    kind: 'predict'
    prompt: 'Sin ejecutar el programa, escribe las dos líneas que crees que mostrará bin/m01_hola.dart.'
    required: true
    hints:
      - 'main se lee de arriba hacia abajo.'
      - 'Cada llamada a print muestra el texto que está entre comillas.'
  - id: 'ejecutar-y-comparar'
    kind: 'code'
    prompt: 'Ejecuta bin/m01_hola.dart desde dart_lab y compara la salida real, línea por línea, con tu predicción.'
    required: true
    hints:
      - 'Confirma que tu terminal está dentro de la carpeta dart_lab.'
      - 'Usa fvm dart run seguido por la ruta bin/m01_hola.dart.'
  - id: 'nombrar-error'
    kind: 'debug'
    prompt: 'Quita temporalmente el punto y coma de la segunda llamada a print, ejecuta fvm dart analyze y describe con tus palabras qué dato del mensaje te ayudó a encontrar el fallo. Después restaura el punto y coma.'
    required: true
    hints:
      - 'El analizador suele indicar archivo, línea, columna y una descripción.'
      - 'No necesitas entender cada palabra: localiza primero dónde ocurrió.'
  - id: 'rastrear-herramienta'
    kind: 'docs'
    prompt: 'Abre la página oficial de dart run, encuentra “Running a Dart file” y explica qué representa bin/m01_hola.dart en el comando.'
    required: true
    hints:
      - 'Busca el encabezado antes de leer toda la página.'
      - 'Compara el ejemplo oficial con tu comando y parafrasea la regla.'
  - id: 'explicar-programa'
    kind: 'explain'
    prompt: 'Explica qué hacen main, las llaves, print, las comillas y el punto y coma sin repetir literalmente esta lección.'
    required: true
    hints:
      - 'Imagina que se lo explicas a alguien que nunca vio código.'
      - 'Distingue la estructura del programa del texto que produce.'
  - id: 'reaplicar-saludo'
    kind: 'transfer'
    prompt: 'Crea bin/m01_practica.dart, escribe de memoria un main que muestre un saludo diferente y ejecútalo con fvm dart run bin/m01_practica.dart.'
    required: true
    hints:
      - 'Este archivo nuevo no viene en el ZIP: tú lo crearás dentro de la carpeta bin.'
      - 'Necesitas la misma estructura; solo cambia el texto entre comillas.'
docRefs:
  - label: 'The main() function'
    url: 'https://dart.dev/language/functions#the-main-function'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'dart run'
    url: 'https://dart.dev/tools/dart-run'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué papel cumplen main, las llaves y print en el programa mínimo?'
  - '¿Qué comando ejecuta bin/m01_hola.dart cuando tu terminal está dentro de dart_lab?'
  - '¿Qué información buscas primero en un mensaje del analizador?'
  - '¿Por qué conviene predecir la salida antes de ejecutar el programa?'
lab:
  workspace: 'dart_lab'
  targetPath: 'bin/m01_hola.dart'
  testCommand: 'fvm dart run bin/m01_hola.dart'
  analyzeCommand: 'fvm dart analyze'
---

Esta **sí es una lección de Dart**. No intenta enseñarte todo el lenguaje en una hora: primero te da la sintaxis mínima para leer y ejecutar un programa real. En D01 comenzarás con valores, tipos, variables y operadores.

## Antes de empezar: consigue el archivo

`bin/m01_hola.dart` no es un archivo imaginario. Está dentro del starter descargable del curso.

1. [Descarga el laboratorio Dart](/downloads/dart_lab_starter.zip).
2. Descomprime el ZIP en una carpeta fácil de encontrar.
3. Si todavía no instalaste el entorno, sigue [la preparación guiada](/inicio/).
4. Abre la **carpeta descomprimida completa** en VS Code.

Debes ver esta estructura:

```text
carpeta-descomprimida/
├── .fvmrc
├── tool/
│   └── preflight.sh
└── dart_lab/
    ├── bin/
    │   └── m01_hola.dart   ← archivo de esta lección
    ├── lib/
    └── test/
```

Si no ves `dart_lab/bin/m01_hola.dart`, detente: abre otra vez el ZIP o vuelve a la preparación. No necesitas inventar ni buscar ese archivo en Internet.

## Tu primer programa, símbolo por símbolo

Este es el programa completo que encontrarás en `dart_lab/bin/m01_hola.dart`:

```dart
// ignore_for_file: avoid_print

void main() {
  print('Hola, Dart');
  print('Estoy aprendiendo a predecir antes de ejecutar');
}
```

La primera línea es una indicación para el analizador del curso. Por ahora puedes dejarla tal como está. El programa comienza en `main`:

| Pieza          | Lectura sencilla                                                             |
| -------------- | ---------------------------------------------------------------------------- |
| `void main()`  | Aquí comienza el programa. `void` indica que `main` no entrega un resultado. |
| `{` y `}`      | Agrupan las instrucciones que pertenecen a `main`.                           |
| `print(...)`   | Muestra un valor en la terminal.                                             |
| `'Hola, Dart'` | Las comillas delimitan un valor de texto.                                    |
| `;`            | Marca el final de una instrucción.                                           |
| `//`           | Comienza un comentario que Dart no ejecuta.                                  |

No memorices las definiciones todavía. Usa esta tabla para poder leer el experimento y vuelve a explicarla con tus propias palabras al final.

## Prepara la terminal una sola vez

La **raíz del starter** es la carpeta que contiene `.fvmrc`, `tool` y `dart_lab`. Abre una terminal allí y ejecuta:

```bash
./tool/preflight.sh
cd dart_lab
fvm dart pub get --enforce-lockfile
```

Después de `cd dart_lab`, tu terminal ya está dentro del paquete de práctica. No vuelvas a escribir `cd dart_lab` en esa misma terminal.

Lee los próximos comandos como oraciones:

- `fvm` usa la versión fijada para el curso.
- `dart` selecciona la herramienta de Dart.
- `run` pide ejecutar un programa.
- `bin/m01_hola.dart` es la ruta del archivo desde `dart_lab`.
- `analyze` revisa el código sin ejecutarlo.

## P — Predice

Abre `bin/m01_hola.dart`, pero todavía no lo ejecutes. Lee las llamadas a `print` de arriba hacia abajo y escribe las dos líneas que esperas ver.

Una predicción obliga a recuperar lo que entendiste. Si primero miras la salida y después dices «sí, tenía sentido», solo estás reconociendo una respuesta ya visible.

## E — Escribe y ejecuta

Ejecuta el archivo desde `dart_lab`:

```bash
fvm dart run bin/m01_hola.dart
```

Compara la salida real con tu predicción, línea por línea. Luego cambia únicamente el texto de la segunda llamada a `print`, guarda y vuelve a ejecutar. Así compruebas el ciclo básico: **editar → guardar → ejecutar → observar**.

## N — Nombra el fallo

Quita temporalmente el `;` de la segunda llamada a `print` y guarda. Ahora consulta el analizador:

```bash
fvm dart analyze
```

No intentes comprender todo el mensaje a la vez. Busca cuatro datos: archivo, línea, columna y descripción. Después restaura el `;`, guarda y ejecuta otra vez `fvm dart analyze` hasta que el error desaparezca.

Completa estas frases:

1. «Yo cambié…»
2. «El analizador señaló…»
3. «La regla que ahora entiendo es…»

## S — Sustenta con la fuente oficial

Abre **dart run** en el panel de fuentes. Usa el índice para llegar a **Running a Dart file** y responde:

- ¿Qué se coloca después de `dart run`?
- ¿Por qué la ruta del curso es `bin/m01_hola.dart`?
- ¿Qué parte del ejemplo oficial coincide con tu comando?

No leas toda la página ni copies un párrafo. Empieza con una pregunta concreta, localiza el encabezado correcto, compara el ejemplo y parafrasea la regla.

## A — Argumenta

Sin mirar la tabla, explica en voz alta qué ocurre desde que Dart entra en `main` hasta que ves dos líneas en la terminal. Incluye las llaves, `print`, las comillas y el punto y coma.

Si solo dices «copié el comando y funcionó», todavía falta el modelo. Una explicación útil conecta cada pieza del código con un efecto observable.

## R — Reaplica

Ahora crearás un archivo nuevo de forma intencional; no debes buscarlo en el ZIP:

1. En el explorador de VS Code, haz clic derecho sobre `dart_lab/bin`.
2. Crea `m01_practica.dart`.
3. Escribe de memoria un `main` con una llamada a `print` y un saludo propio.
4. Ejecútalo desde `dart_lab`:

```bash
fvm dart run bin/m01_practica.dart
```

Si funciona, ya hiciste más que observar un ejemplo: reconociste su estructura y la aplicaste en otro archivo. En la próxima lección estudiarás qué valores puede guardar Dart y cómo nombrarlos con variables.

## Regla sobre las pistas y la IA

Una pista útil reduce el espacio del problema sin hacer el trabajo central. Puede pedirte que leas una línea, que localices un símbolo o que consultes un encabezado. Usa una respuesta completa solo después de intentar, ejecutar, leer el error y escribir lo que ya descartaste.
