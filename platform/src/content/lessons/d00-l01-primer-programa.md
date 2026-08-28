---
id: 'D00-L01'
trackId: 'dart'
moduleId: 'D00'
kind: 'taller'
order: 0
slug: 'como-estudiar-programacion'
title: 'Tu primer programa en Dart'
summary: 'Consigue el laboratorio, reconoce la sintaxis mínima de un programa Dart y ejecútalo después de predecir su salida.'
estimatedMinutes: 45
objectives:
  - 'Encontrar el starter y abrir dart_lab/bin/m01_hola.dart sin adivinar rutas.'
  - 'Reconocer main, llaves, print, texto entre comillas y punto y coma.'
  - 'Ejecutar un archivo Dart desde la terminal y comparar la salida con tu predicción.'
prerequisites: []
activities:
  - id: 'predecir-salida'
    kind: 'attempt'
    prompt: 'Sin ejecutar el programa, escribe las dos líneas exactas que crees que mostrará bin/m01_hola.dart.'
    required: true
    hints:
      - 'main se lee de arriba hacia abajo.'
      - 'Cada llamada a print muestra el texto que está entre comillas.'
  - id: 'ejecutar-y-comparar'
    kind: 'evidence'
    prompt: 'Ejecuta bin/m01_hola.dart desde dart_lab y pega la salida real. Compárala línea por línea con tu predicción.'
    required: true
    hints:
      - 'Confirma que tu terminal está dentro de la carpeta dart_lab.'
      - 'Usa fvm dart run seguido por la ruta bin/m01_hola.dart.'
  - id: 'rastrear-herramienta'
    kind: 'source'
    prompt: 'Abre la página oficial de dart run, encuentra «Running a Dart file» y explica qué representa bin/m01_hola.dart dentro del comando.'
    required: true
    sourceLabel: 'dart run'
    hints:
      - 'Busca el encabezado antes de leer toda la página.'
      - 'Compara el ejemplo oficial con tu comando y parafrasea la regla.'
  - id: 'explicar-programa'
    kind: 'judgment'
    prompt: 'Explica qué hacen main, las llaves, print, las comillas y el punto y coma, y decide qué parte del programa cambiarías si quisieras una tercera línea.'
    required: true
    hints:
      - 'Imagina que se lo explicas a alguien que nunca vio código.'
      - 'Distingue la estructura del programa del texto que produce.'
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
  - 'En un archivo vacío, vuelve a escribir un main completo con dos llamadas a print y ejecútalo sin mirar la lección.'
  - 'Explica en voz alta qué ocurre desde que Dart entra en main hasta que ves dos líneas en la terminal.'
  - 'Crea bin/m01_saludo.dart con un saludo propio en tres líneas y ejecútalo sin copiar el archivo original.'
lab:
  workspace: 'dart_lab'
  targetPath: 'bin/m01_hola.dart'
  testCommand: 'fvm dart run bin/m01_hola.dart'
  analyzeCommand: 'fvm dart analyze'
---

Esta **sí es una lección de Dart**. No intenta enseñarte todo el lenguaje en una hora: te da la sintaxis mínima para leer y ejecutar un programa real. En D01 empezarás con valores, tipos y variables.

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

La primera línea es una indicación para el analizador del curso. Por ahora déjala tal como está. El programa comienza en `main`:

| Pieza          | Lectura sencilla                                                             |
| -------------- | ---------------------------------------------------------------------------- |
| `void main()`  | Aquí comienza el programa. `void` indica que `main` no entrega un resultado. |
| `{` y `}`      | Agrupan las instrucciones que pertenecen a `main`.                           |
| `print(...)`   | Muestra un valor en la terminal.                                             |
| `'Hola, Dart'` | Las comillas delimitan un valor de texto.                                    |
| `;`            | Marca el final de una instrucción.                                           |
| `//`           | Comienza un comentario que Dart no ejecuta.                                  |

No memorices las definiciones todavía. Usa la tabla para poder leer el experimento y vuelve a explicarla con tus palabras al final.

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

## Intento · antes de mirar

Abre `bin/m01_hola.dart`, pero todavía no lo ejecutes. Lee las llamadas a `print` de arriba hacia abajo y escribe las dos líneas que esperas ver.

Una predicción obliga a recuperar lo que entendiste. Si primero miras la salida y después dices «sí, tenía sentido», solo estás reconociendo una respuesta ya visible.

## Evidencia · ejecuta y compara

Ejecuta el archivo desde `dart_lab`:

```bash
fvm dart run bin/m01_hola.dart
```

Copia la salida tal cual aparece y compárala con tu predicción, línea por línea. Luego cambia únicamente el texto de la segunda llamada a `print`, guarda y vuelve a ejecutar. Acabas de recorrer el ciclo básico: **editar → guardar → ejecutar → observar**.

## Fuente · lee con una pregunta

Abre **dart run** en el panel de fuentes. Usa el índice para llegar a **Running a Dart file** y responde:

- ¿Qué se coloca después de `dart run`?
- ¿Por qué la ruta del curso es `bin/m01_hola.dart`?
- ¿Qué parte del ejemplo oficial coincide con tu comando?

No leas toda la página ni copies un párrafo. Empieza con una pregunta concreta, localiza el encabezado correcto, compara el ejemplo y parafrasea la regla.

## Criterio · decide y acepta el costo

Sin mirar la tabla, explica en voz alta qué ocurre desde que Dart entra en `main` hasta que ves dos líneas en la terminal. Después decide: para agregar una tercera línea, ¿tocas `main`, agregas otro `print` o creas otro archivo? Nombra la opción que descartaste y por qué.

Si solo dices «copié el comando y funcionó», todavía falta el modelo. Una explicación útil conecta cada pieza del código con un efecto observable.

En la próxima lección vas a romper este mismo programa a propósito para aprender a leer lo que dice el analizador.
