---
id: 'F01-L01'
trackId: 'flutter'
moduleId: 'F01'
kind: 'taller'
order: 0
slug: 'constraints-layout-responsive'
title: 'El espacio se negocia, no se adivina'
summary: 'Sigue la cadena constraints abajo, tamaños arriba y posiciones las decide el padre, sobre un árbol real.'
estimatedMinutes: 60
objectives:
  - 'Explicar el flujo constraints down, sizes up, parents set positions.'
  - 'Rastrear qué límite recibe un widget siguiendo la cadena desde la raíz.'
  - 'Reconocer por qué un hijo no puede elegir cualquier tamaño.'
prerequisites: ['F00-L04']
activities:
  - id: 'predecir-ancho'
    kind: 'attempt'
    prompt: 'Sin ejecutar la app, predice el ancho que recibe el título dentro de Center, ConstrainedBox con maxWidth 1120 y Row con Expanded, cuando la ventana mide 360 y 1400 px.'
    required: true
    hints:
      - 'El límite baja desde la raíz; cada widget puede estrecharlo pero no ampliarlo.'
      - 'Expanded reparte lo que sobra después de los hijos de tamaño fijo.'
  - id: 'medir-ancho'
    kind: 'evidence'
    prompt: 'Envuelve el título en un LayoutBuilder temporal que imprima las constraints recibidas, ejecuta la app en dos anchos y pega las dos líneas impresas.'
    required: true
    hints:
      - 'LayoutBuilder recibe las constraints exactas de su posición.'
      - 'Quita el print cuando termines: la evidencia es la salida, no el código.'
  - id: 'sustentar-constraints'
    kind: 'source'
    prompt: 'En Understanding constraints, encuentra la frase que resume la regla de tres partes y anota su encabezado.'
    required: true
    sourceLabel: 'Understanding constraints'
    hints:
      - 'La regla se enuncia en una sola oración cerca del principio.'
      - 'Fíjate en el orden: primero bajan, después suben, después se posiciona.'
  - id: 'defender-limite'
    kind: 'judgment'
    prompt: 'Decide si el ancho máximo de la pantalla debe declararse con ConstrainedBox o dejarse libre, y nombra qué se rompe con cada opción en una ventana muy ancha.'
    required: true
    hints:
      - 'Una línea de texto de 1400 px es incómoda de leer.'
      - 'Un ancho máximo desperdicia espacio si la pantalla muestra una tabla densa.'
docRefs:
  - label: 'Understanding constraints'
    url: 'https://docs.flutter.dev/ui/layout/constraints'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'LayoutBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué baja por el árbol, qué sube y quién decide la posición final?'
  - 'En un archivo vacío, vuelve a escribir un árbol Center, ConstrainedBox y Row sin mirar la lección.'
  - 'Explica en voz alta por qué un hijo no puede escoger cualquier tamaño que quiera.'
  - 'Toma una pantalla que desborde en móvil y rastrea qué widget impone el límite que la rompe.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

La mayoría de los problemas de layout en Flutter vienen de intentar responder «¿de qué tamaño es este widget?» cuando la pregunta correcta es «¿qué límites recibió?».

## La regla de tres partes

> Las **constraints bajan**. Los **tamaños suben**. El **padre decide la posición**.

Traducido:

1. Un padre le dice a su hijo entre qué mínimo y qué máximo puede medir.
2. El hijo elige un tamaño **dentro** de ese rango y se lo informa al padre.
3. El padre decide dónde colocarlo.

Un hijo nunca elige un tamaño libremente: elige dentro de lo que le dejaron. Por eso `width: 500` a veces se ignora — no es que Flutter lo desobedezca, es que el padre impuso un máximo menor.

## Seguir la cadena

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1120),
    child: Row(
      children: <Widget>[Expanded(child: _Header(...))],
    ),
  ),
)
```

Con una ventana de 1400 px: `Center` pasa hasta 1400, `ConstrainedBox` lo estrecha a 1120, `Row` reparte esos 1120 entre sus hijos, y `Expanded` toma lo que sobra.

Con una ventana de 360 px: `ConstrainedBox` no amplía nada — su `maxWidth` es un techo, no un piso. El límite efectivo es 360.

**Un widget puede estrechar el límite que recibe, nunca ampliarlo.** Esa frase resuelve la mitad de los «no se ve como esperaba».

## Intento · antes de mirar

Con el árbol de arriba, completa la tabla antes de ejecutar nada:

| Ventana | Ancho que recibe `_Header` |
| ------- | -------------------------- |
| 360 px  | ?                          |
| 1400 px | ?                          |

## Evidencia · ejecuta y compara

Envuelve el título en un `LayoutBuilder` temporal:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    debugPrint('constraints: $constraints');
    return _Header(entryCount: state.entries.length);
  },
)
```

Ejecuta la app, cambia el ancho de la ventana y pega las dos líneas impresas. Compáralas con tu predicción. Después quita el `LayoutBuilder` temporal.

## Fuente · lee con una pregunta

Abre **Understanding constraints** y busca la oración que resume la regla. Pregunta concreta: ¿en qué orden ocurren las tres cosas? Anota el encabezado; vas a volver a esta página cada vez que un layout te sorprenda.

## Criterio · decide y acepta el costo

Defiende el `maxWidth: 1120`. Sin él, una ventana de 2560 px produce líneas de texto imposibles de leer. Con él, una pantalla que muestre una tabla densa desperdicia la mitad del monitor.

Elige para esta app y nombra el caso donde tu decisión envejece mal. En la próxima lección el problema pasa a ser cómo se reparte el espacio **entre hermanos**.
