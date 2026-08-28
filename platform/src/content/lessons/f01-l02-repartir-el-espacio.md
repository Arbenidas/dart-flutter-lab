---
id: 'F01-L02'
trackId: 'flutter'
moduleId: 'F01'
kind: 'taller'
order: 1
slug: 'repartir-el-espacio-entre-hermanos'
title: 'Expanded reparte lo que sobra'
summary: 'Distingue Expanded, Flexible y tamaño intrínseco, y provoca el desbordamiento a propósito para entender de dónde sale.'
estimatedMinutes: 55
objectives:
  - 'Elegir entre Expanded, Flexible y un hijo de tamaño natural dentro de un Row o Column.'
  - 'Explicar de dónde sale un desbordamiento y qué widget lo produce.'
  - 'Leer el mensaje de overflow como un diagnóstico y no como un adorno.'
prerequisites: ['F01-L01']
activities:
  - id: 'predecir-reparto'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice cómo se reparten 600 px entre un icono de 48 px, un texto dentro de Expanded y un botón de 120 px.'
    required: true
    hints:
      - 'Los hijos de tamaño fijo se sirven primero.'
      - 'Expanded recibe lo que queda, no una fracción del total.'
  - id: 'provocar-overflow'
    kind: 'evidence'
    prompt: 'Quita el Expanded que envuelve al título, ejecuta la app en una ventana angosta y pega el mensaje de desbordamiento que aparece en la consola.'
    required: true
    hints:
      - 'Sin Expanded, un texto largo pide todo el ancho que necesita.'
      - 'El mensaje nombra el widget y cuántos píxeles sobran.'
  - id: 'sustentar-flex'
    kind: 'source'
    prompt: 'En Understanding constraints, localiza qué dice sobre los hijos flexibles dentro de Row y Column y qué diferencia hay entre ajustar y ocupar.'
    required: true
    sourceLabel: 'Understanding constraints'
    hints:
      - 'Busca la palabra flex o unbounded dentro de la página.'
      - 'Anota el encabezado y una paráfrasis corta.'
  - id: 'defender-expanded'
    kind: 'judgment'
    prompt: 'Decide entre Expanded y Flexible para el título de la barra, y nombra qué cambia visualmente en una ventana muy ancha.'
    required: true
    hints:
      - 'Expanded obliga a ocupar todo el espacio asignado; Flexible permite quedarse más chico.'
      - 'Piensa qué pasa con el fondo o el subrayado del widget en cada caso.'
docRefs:
  - label: 'Understanding constraints'
    url: 'https://docs.flutter.dev/ui/layout/constraints'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'General approach to adaptive apps'
    url: 'https://docs.flutter.dev/ui/adaptive-responsive/general'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo se reparte el espacio entre hijos fijos y flexibles dentro de un Row?'
  - 'En un archivo vacío, vuelve a escribir un Row con un hijo fijo y uno Expanded, sin mirar la lección.'
  - 'Explica en voz alta de dónde sale un desbordamiento y qué información trae su mensaje.'
  - 'Diseña una barra con icono, título y dos acciones que no desborde nunca; define qué cede primero.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Un `Row` no reparte el espacio en partes iguales. Sirve primero a los hijos que piden un tamaño concreto y reparte **lo que sobra** entre los flexibles.

## El orden del reparto

```dart
Row(
  children: <Widget>[
    Icon(Icons.book, size: 48),      // pide 48
    Expanded(child: Text(titulo)),   // recibe lo que sobre
    SizedBox(width: 120, child: boton), // pide 120
  ],
)
```

Con 600 px disponibles: 48 + 120 = 168 para los fijos, y `Expanded` recibe los 432 restantes. No es «un tercio cada uno».

## Expanded y Flexible no son sinónimos

|            | qué hace                                               |
| ---------- | ------------------------------------------------------ |
| `Expanded` | **obliga** al hijo a ocupar todo el espacio asignado   |
| `Flexible` | le **permite** ocuparlo, pero puede quedarse más chico |

La diferencia se ve cuando el hijo tiene fondo, borde o subrayado: con `Expanded` esa decoración se estira hasta el final; con `Flexible` termina donde termina el contenido.

## El desbordamiento es un diagnóstico

Sin ningún hijo flexible, un texto largo pide todo el ancho que necesita, el `Row` no puede dárselo y aparece la franja amarilla y negra con un mensaje como:

```text
A RenderFlex overflowed by 137 pixels on the right.
```

Ese mensaje trae dos datos valiosos: **qué widget** desbordó y **cuántos píxeles**. No es un adorno de error: es la herramienta diciéndote exactamente cuánto espacio falta y quién lo pidió.

## Intento · antes de mirar

Completa el reparto antes de ejecutar: 600 px, un icono de 48, un texto en `Expanded` y un botón de 120. ¿Cuánto recibe cada uno? ¿Y si la ventana baja a 150 px?

## Evidencia · provoca el fallo

Abre `journal_view.dart`, quita el `Expanded` que envuelve al título y ejecuta la app en una ventana angosta. Pega el mensaje de desbordamiento completo.

Después restaura el `Expanded` y confirma que desaparece. Provocar el error a propósito y leerlo entero es más rápido que evitarlo y encontrártelo dentro de seis semanas.

## Fuente · lee con una pregunta

Abre **Understanding constraints** y busca lo que dice sobre hijos flexibles. Pregunta concreta: ¿qué diferencia hay entre un hijo que se ajusta y uno que ocupa? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende `Expanded` o `Flexible` para el título de la barra. Con `Expanded`, el título siempre ocupa el hueco y empuja las acciones al borde. Con `Flexible`, en una ventana ancha el título termina donde termina el texto y las acciones quedan pegadas a él.

Elige y nombra qué se ve peor en el caso extremo. En la próxima lección el espacio deja de alcanzar y hay que decidir qué se mueve de línea.
