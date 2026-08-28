---
id: 'F01-L04'
trackId: 'flutter'
moduleId: 'F01'
kind: 'taller'
order: 3
slug: 'layoutbuilder-cambia-relaciones'
title: 'LayoutBuilder pregunta el espacio antes de construir'
summary: 'Cambia la composición según el ancho local disponible en vez de consultar el tamaño de la pantalla.'
estimatedMinutes: 60
objectives:
  - 'Usar LayoutBuilder para decidir la composición a partir del espacio local.'
  - 'Explicar por qué el ancho de la ventana no es el ancho disponible para un widget.'
  - 'Definir un punto de corte a partir del contenido y no de un modelo de teléfono.'
prerequisites: ['F01-L03']
activities:
  - id: 'predecir-compact'
    kind: 'attempt'
    prompt: 'Sin ejecutar la app, predice en cuáles de estos anchos de ventana el encabezado usará su forma compacta: 360, 719, 720 y 1400 px.'
    required: true
    hints:
      - 'El corte de la bitácora compara contra 720 px.'
      - 'La comparación usa el ancho que recibe el widget, no el de la ventana.'
  - id: 'mover-corte'
    kind: 'evidence'
    prompt: 'Cambia el punto de corte de 720 a 1000 en _Header, ejecuta la app en una ventana mediana y pega qué forma aparece antes y después del cambio.'
    required: true
    hints:
      - 'El valor está en la comparación dentro del builder de LayoutBuilder.'
      - 'Deja el valor original cuando termines el experimento.'
  - id: 'sustentar-layoutbuilder'
    kind: 'source'
    prompt: 'En LayoutBuilder class, encuentra qué recibe el builder y en qué momento se ejecuta respecto de la fase de layout.'
    required: true
    sourceLabel: 'LayoutBuilder class'
    hints:
      - 'Busca el tipo del segundo parámetro del builder.'
      - 'Fíjate si la página dice que el builder puede ejecutarse más de una vez.'
  - id: 'defender-corte'
    kind: 'judgment'
    prompt: 'Decide si el punto de corte debe salir del ancho de un dispositivo conocido o del contenido, y nombra el costo de cada criterio.'
    required: true
    hints:
      - 'Una lista de anchos de teléfonos envejece con cada modelo nuevo.'
      - 'Un corte por contenido exige medir cuándo el texto empieza a leerse mal.'
docRefs:
  - label: 'LayoutBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'General approach to adaptive apps'
    url: 'https://docs.flutter.dev/ui/adaptive-responsive/general'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué el ancho de la ventana no es el ancho disponible para un widget?'
  - 'En un archivo vacío, vuelve a escribir un LayoutBuilder que elija entre dos composiciones, sin mirar la lección.'
  - 'Explica en voz alta cómo elegirías un punto de corte a partir del contenido.'
  - 'Aplica un LayoutBuilder a otra parte de la pantalla y define qué relación cambia, no qué tamaño.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Hasta aquí el layout reaccionaba al espacio. `LayoutBuilder` te deja **preguntarlo** antes de decidir qué construir.

## Cómo se usa

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final compact = constraints.maxWidth < 720;
    return compact ? _VerticalHeader() : _HorizontalHeader();
  },
)
```

El `builder` recibe las `constraints` **de esa posición del árbol** y se ejecuta durante la fase de layout, cuando ya se sabe cuánto espacio hay. Puede ejecutarse varias veces si el espacio cambia.

## El ancho de la ventana no es tu ancho

Esta es la diferencia que hace útil a `LayoutBuilder` frente a consultar `MediaQuery.sizeOf(context).width`:

- `MediaQuery` te da el tamaño de **la ventana**.
- `LayoutBuilder` te da el espacio que le queda **a ese widget**.

En una ventana de 1400 px, un panel lateral puede tener 320 px disponibles. Si decides la composición del panel con el ancho de la ventana, construyes la versión ancha dentro de un hueco angosto y desbordas. El widget solo puede razonar sobre su propio espacio.

## Cambiar relaciones, no tamaños

Fíjate en qué hace el corte de la bitácora: en modo compacto el encabezado apila los elementos y reduce el tamaño del título. No escala todo proporcionalmente — **cambia la relación** entre las piezas. Ese es el patrón: en angosto, apilar; en ancho, alinear.

## Intento · antes de mirar

Predice qué forma usará el encabezado en cada ancho de ventana:

| Ventana | ¿compacta o amplia? |
| ------- | ------------------- |
| 360 px  | ?                   |
| 719 px  | ?                   |
| 720 px  | ?                   |
| 1400 px | ?                   |

Presta atención al caso exacto de 720: la comparación es estricta.

## Evidencia · ejecuta y compara

En `_Header`, cambia el corte de `720` a `1000`. Ejecuta la app en una ventana mediana y pega qué forma aparece antes y después del cambio. Después restaura el valor original.

Un experimento más: envuelve `_Header` en un `SizedBox(width: 400)` dentro de una ventana ancha. ¿Qué forma elige ahora? Esa respuesta es la sección «el ancho de la ventana no es tu ancho», comprobada.

## Fuente · lee con una pregunta

Abre **LayoutBuilder class**. Dos preguntas: ¿qué tipo tiene el segundo parámetro del `builder`?, ¿puede ejecutarse más de una vez? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende de dónde sale el número del corte. Copiar el ancho de un teléfono conocido es fácil y envejece con cada modelo nuevo; medir cuándo el contenido empieza a verse mal cuesta trabajo y sobrevive a los dispositivos.

Elige y nombra el costo. Cierra el módulo:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
```

En F02 la pregunta deja de ser el espacio y pasa a ser **quién es dueño de cada dato** que cambia.
