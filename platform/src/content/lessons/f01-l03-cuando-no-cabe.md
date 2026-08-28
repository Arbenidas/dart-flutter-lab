---
id: 'F01-L03'
trackId: 'flutter'
moduleId: 'F01'
kind: 'taller'
order: 2
slug: 'cuando-el-contenido-no-cabe'
title: 'Cuando no cabe: envolver, recortar o desplazar'
summary: 'Compara Wrap, elipsis y scroll como tres respuestas distintas al mismo problema y decide cuál corresponde.'
estimatedMinutes: 50
objectives:
  - 'Elegir entre Wrap, recorte con elipsis y desplazamiento según el tipo de contenido.'
  - 'Explicar qué información pierde cada estrategia.'
  - 'Reconocer cuándo un desbordamiento indica un problema de diseño y no de código.'
prerequisites: ['F01-L02']
activities:
  - id: 'predecir-estrategia'
    kind: 'attempt'
    prompt: 'Sin escribir código, decide qué estrategia usarías para una fila de etiquetas, para un título largo y para una lista de cien entradas, y por qué.'
    required: true
    hints:
      - 'Cada estrategia pierde algo distinto: posición, texto o visibilidad inmediata.'
      - 'Pregúntate si el usuario necesita ver todo a la vez.'
  - id: 'probar-wrap'
    kind: 'evidence'
    prompt: 'Cambia un Row de acciones por un Wrap en journal_view.dart, ejecuta la app en una ventana angosta y pega la diferencia que observas frente al desbordamiento anterior.'
    required: true
    hints:
      - 'Wrap mueve a la línea siguiente lo que no cabe.'
      - 'Compara qué pasaba antes con el mismo ancho.'
  - id: 'sustentar-adaptive'
    kind: 'source'
    prompt: 'En General approach to adaptive apps, encuentra qué recomienda sobre cambiar la disposición en vez de escalar todo proporcionalmente.'
    required: true
    sourceLabel: 'General approach to adaptive apps'
    hints:
      - 'Busca la parte que distingue adaptive de responsive.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-estrategia'
    kind: 'judgment'
    prompt: 'Elige una estrategia para la barra de acciones de la bitácora y nombra qué información pierde el usuario con tu elección.'
    required: true
    hints:
      - 'Una elipsis oculta texto sin avisar que había más.'
      - 'Un scroll horizontal es fácil de no descubrir en escritorio.'
docRefs:
  - label: 'General approach to adaptive apps'
    url: 'https://docs.flutter.dev/ui/adaptive-responsive/general'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Understanding constraints'
    url: 'https://docs.flutter.dev/ui/layout/constraints'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo usarías Wrap y cuándo un recorte con elipsis?'
  - 'En un archivo vacío, vuelve a escribir un Wrap con espaciado entre hijos, sin mirar la lección.'
  - 'Explica en voz alta qué información pierde cada estrategia cuando el contenido no cabe.'
  - 'Diseña la misma lista de acciones para 320, 768 y 1280 px; define qué se mantiene y qué cambia de eje.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Cuando el contenido no cabe hay exactamente tres respuestas, y elegir mal no produce un error: produce una interfaz que esconde información sin decirlo.

## Tres estrategias

| Estrategia                                          | Qué hace                                 | Qué pierde                     |
| --------------------------------------------------- | ---------------------------------------- | ------------------------------ |
| **Envolver** (`Wrap`)                               | pasa a la línea siguiente lo que no cabe | la alineación en una sola fila |
| **Recortar** (`TextOverflow.ellipsis`)              | corta el texto y pone puntos suspensivos | el texto que quedó fuera       |
| **Desplazar** (`SingleChildScrollView`, `ListView`) | permite mover el contenido               | la visibilidad inmediata       |

Ninguna es la correcta siempre. La pregunta es qué puede permitirse perder **ese** contenido:

- Una fila de etiquetas: envolver. El orden importa poco y todas deben verse.
- Un título de una entrada: recortar. El texto completo está a un toque de distancia.
- Una lista de cien entradas: desplazar. Nunca iban a caber y el usuario lo espera.

## Wrap en una línea

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: acciones,
)
```

`spacing` separa hijos en la misma línea; `runSpacing` separa las líneas entre sí. Un `Wrap` no desborda: por eso también sirve como red de seguridad cuando no sabes qué anchos van a llegar.

## Adaptive no es escalar

Hacer todo proporcionalmente más chico en una pantalla angosta produce texto ilegible y áreas táctiles imposibles. Adaptarse significa **cambiar la disposición**: pasar de fila a columna, mover acciones a un menú, esconder lo secundario. Los tamaños de fuente y las áreas táctiles se quedan donde estaban.

## Intento · antes de mirar

Decide, por escrito y antes de tocar código, qué estrategia usarías para: una fila de etiquetas, un título largo y una lista de cien entradas. Justifica cada una con lo que está dispuesta a perder.

## Evidencia · ejecuta y compara

Cambia el `Row` de acciones de `journal_view.dart` por un `Wrap` y ejecuta la app en una ventana angosta. Pega lo que observas frente al desbordamiento de la lección anterior: dónde estaba la franja amarilla y qué hay ahora en su lugar.

## Fuente · lee con una pregunta

Abre **General approach to adaptive apps** con una pregunta concreta: ¿qué recomienda sobre cambiar la disposición frente a escalar todo? Anota el encabezado y la frase que lo dice.

## Criterio · decide y acepta el costo

Elige una estrategia para la barra de acciones de la bitácora y nombra explícitamente qué pierde el usuario. Una elipsis oculta texto sin avisar que había más; un scroll horizontal en escritorio es fácil de no descubrir; un `Wrap` hace que la barra cambie de alto y empuje el contenido de abajo.

En la próxima lección dejas de reaccionar al espacio y empiezas a **preguntarlo** antes de construir.
