---
id: 'F00-L01'
trackId: 'flutter'
moduleId: 'F00'
kind: 'taller'
order: 0
slug: 'widgets-como-descripciones'
title: 'Un widget describe; Flutter hace el resto'
summary: 'Separa Widget, Element y RenderObject, y entiende por qué reconstruir una descripción no es redibujar la pantalla.'
estimatedMinutes: 55
objectives:
  - 'Explicar por qué un Widget es una descripción inmutable de interfaz.'
  - 'Distinguir el árbol de widgets del árbol de elements y del de render objects.'
  - 'Leer un árbol de widgets y decir qué nodo contiene a cuál.'
prerequisites: ['D04-L06']
activities:
  - id: 'predecir-arbol'
    kind: 'attempt'
    prompt: 'Dibuja el árbol que produce MaterialApp > Scaffold > Center > Text y predice qué nodo contiene a cuál, sin abrir la app.'
    required: true
    hints:
      - 'Cada widget del árbol se declara dentro del anterior.'
      - 'La indentación del código ya dibuja el árbol.'
  - id: 'ejecutar-app'
    kind: 'evidence'
    prompt: 'Ejecuta la app en Chrome, cambia el título de MaterialApp en lib/app.dart, recarga y pega lo que ves en la terminal al hacerlo.'
    required: true
    hints:
      - 'El comando de ejecución está en el README de flutter_lab.'
      - 'El hot reload no reinicia el estado; el hot restart sí.'
  - id: 'sustentar-widget'
    kind: 'source'
    prompt: 'En Widget class, encuentra qué dice la documentación sobre inmutabilidad y sobre la relación entre Widget y Element.'
    required: true
    sourceLabel: 'Widget class'
    hints:
      - 'Busca la palabra immutable en la descripción de la clase.'
      - 'Anota el encabezado, no el párrafo entero.'
  - id: 'defender-descripcion'
    kind: 'judgment'
    prompt: 'Decide qué se gana al tratar la interfaz como una descripción que se vuelve a construir, frente a mutar objetos de pantalla, y nombra el costo.'
    required: true
    hints:
      - 'Reconstruir una descripción es barato; redibujar píxeles no lo es.'
      - 'Flutter compara descripciones para decidir qué cambia de verdad.'
docRefs:
  - label: 'Widget class'
    url: 'https://api.flutter.dev/flutter/widgets/Widget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Create widgets'
    url: 'https://docs.flutter.dev/learn/pathway/tutorial/widget-fundamentals'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué significa afirmar que un Widget es una descripción inmutable?'
  - 'En un archivo vacío, vuelve a escribir el árbol MaterialApp > Scaffold > Center > Text sin mirar nada.'
  - 'Explica en voz alta la diferencia entre el árbol de widgets y el árbol de elements.'
  - 'Dibuja el árbol de una pantalla de una app que uses a diario y marca qué nodos serían widgets propios.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/app.dart'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
---

Esta es la idea que hay que entender antes que cualquier API: en Flutter **no mueves cosas en la pantalla**. Escribes una descripción de cómo debería verse la pantalla, y el framework se ocupa del resto.

## Tres piezas que no son lo mismo

| Pieza          | Qué es                                                | Quién la maneja |
| -------------- | ----------------------------------------------------- | --------------- |
| `Widget`       | una descripción inmutable, barata de crear y tirar    | vos             |
| `Element`      | la instancia viva que persiste entre reconstrucciones | el framework    |
| `RenderObject` | lo que mide, posiciona y pinta                        | el framework    |

Cuando cambias algo, creas **widgets nuevos**. Flutter compara la descripción nueva con la anterior y actualiza solo los `RenderObject` que de verdad cambiaron. Por eso reconstruir es barato: reconstruir una descripción no es redibujar la pantalla.

## Preparar el laboratorio local

Desde la raíz del starter:

```bash
cd flutter_lab
fvm flutter pub get --enforce-lockfile
fvm flutter run -d chrome
```

La app es una bitácora: una lista de entradas con título y cuerpo. Vas a trabajar sobre ella durante todo el recorrido Flutter.

## Leer un árbol

```dart
MaterialApp(
  title: 'Flutter Lab — Bitácora',
  theme: AppTheme.light,
  home: const JournalView(),
)
```

La indentación **es** el árbol. `MaterialApp` contiene a `JournalView`, que contiene a un `Scaffold`, que contiene el resto. Aprender a leer esta anidación de un vistazo es la mitad del trabajo de depurar layout.

## Intento · antes de mirar

Sin abrir `lib/app.dart`, dibuja en papel el árbol de `MaterialApp > Scaffold > Center > Text` y anota qué nodo es padre de cuál. Predice también qué pasa si mueves `Center` para que envuelva a `Scaffold` en lugar de estar dentro.

## Evidencia · ejecuta y compara

Corre la app, abre `lib/app.dart` y cambia el `title` del `MaterialApp`. Guarda y observa el hot reload. Pega la salida de la terminal.

Después prueba lo contrario: agrega un `print` dentro del `build` de `FlutterLabApp` y cuenta cuántas veces se ejecuta. Eso es lo que significa que reconstruir sea barato.

## Fuente · lee con una pregunta

Abre **Widget class** con una pregunta concreta: ¿qué dice sobre la inmutabilidad y sobre la relación entre `Widget` y `Element`? Anota el encabezado y una paráfrasis.

## Criterio · decide y acepta el costo

Defiende el modelo declarativo frente al imperativo. Mutar un objeto de pantalla parece más directo: cambias una propiedad y listo. Reconstruir una descripción completa parece un desperdicio hasta que ves que el framework compara y actualiza solo lo necesario.

Nombra el costo real del modelo declarativo: cada `build` tiene que poder producir la interfaz **entera** a partir del estado actual, así que el estado tiene que estar en un lugar donde `build` lo alcance. Esa restricción es la que gobierna F02 y F05.

En la próxima lección construyes tu propio widget en vez de leer los que ya existen.
