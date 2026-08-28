---
id: 'F05-L01'
trackId: 'flutter'
moduleId: 'F05'
kind: 'taller'
order: 0
slug: 'mvvm-feature-first-riverpod-notifier'
title: 'Arquitectura es decidir dónde cambia cada cosa'
summary: 'Asigna responsabilidades a View, ViewModel y Repository por sus entradas y salidas, sin crear capas ceremoniales.'
estimatedMinutes: 60
objectives:
  - 'Describir View, ViewModel y Repository por lo que recibe y lo que devuelve cada uno.'
  - 'Detectar lógica de presentación que se filtró a la capa de datos, y al revés.'
  - 'Justificar cuándo una capa adicional aporta y cuándo solo agrega ceremonia.'
prerequisites: ['F04-L04']
activities:
  - id: 'asignar-responsabilidades'
    kind: 'attempt'
    prompt: 'Sin abrir el código, decide en qué capa vive cada cosa: recortar espacios de un título, ordenar la lista por fecha, mostrar un mensaje de error y decidir el texto de ese mensaje.'
    required: true
    hints:
      - 'Pregúntate qué capa cambiaría si mañana la interfaz fuera una CLI.'
      - 'Una capa que solo reenvía llamadas no está aportando nada.'
  - id: 'rastrear-capas'
    kind: 'evidence'
    prompt: 'Recorre journal_view_model.dart y journal_repository.dart y anota qué recibe y qué devuelve cada método público. Ejecuta las pruebas del ViewModel y pega la salida.'
    required: true
    hints:
      - 'El Repository no conoce widgets ni mensajes para el usuario.'
      - 'El ViewModel no conoce cómo se dibuja la lista.'
  - id: 'sustentar-arquitectura'
    kind: 'source'
    prompt: 'En Common architecture concepts, encuentra qué responsabilidad asigna la documentación a la capa de datos y cuál a la de presentación.'
    required: true
    sourceLabel: 'Common architecture concepts'
    hints:
      - 'Busca los nombres de las capas y su descripción de una línea.'
      - 'Anota el encabezado y la frontera que más te sorprenda.'
  - id: 'defender-capa'
    kind: 'judgment'
    prompt: 'Decide si la bitácora necesita una capa Service entre ViewModel y Repository, y nombra qué problema concreto justificaría agregarla.'
    required: true
    hints:
      - 'Una capa que solo reenvía llamadas cuesta lectura y no compra nada.'
      - 'Un Service empieza a valer cuando coordina más de una fuente de datos.'
docRefs:
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Guide to app architecture'
    url: 'https://docs.flutter.dev/app-architecture/guide'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué transforma un ViewModel y qué coordina un Repository?'
  - 'En un archivo vacío, escribe las firmas públicas de un Repository de bitácora sin mirar el original.'
  - 'Explica en voz alta cómo detectas que la lógica de presentación se filtró a la capa de datos.'
  - 'Toma una feature de otro proyecto y reparte sus responsabilidades en tres capas, justificando cada frontera.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view_model.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

«Arquitectura» suena a diagramas. En la práctica es una sola pregunta repetida: **cuando esto cambie, ¿qué archivos tengo que tocar?**

## Tres capas por sus entradas y salidas

| Capa           | Recibe               | Devuelve           | No sabe nada de                |
| -------------- | -------------------- | ------------------ | ------------------------------ |
| **View**       | estado               | widgets            | de dónde vienen los datos      |
| **ViewModel**  | acciones del usuario | estado inmutable   | cómo se dibuja nada            |
| **Repository** | peticiones de datos  | modelos de dominio | widgets ni mensajes al usuario |

La prueba práctica para saber si una responsabilidad está en su sitio: **¿qué capa tendría que reescribir si mañana esta app fuera una CLI?** La View entera. El ViewModel casi nada. El Repository, nada.

## Dónde se filtra la lógica

Dos filtraciones frecuentes, las dos en la bitácora vale la pena mirarlas:

- **Recortar espacios de un título** está en el `ViewModel`. Es una regla del dominio, no de la pantalla: si llegara por importación también habría que aplicarla.
- **Ordenar por fecha de actualización** está en el `Repository`. Es una propiedad de cómo se entregan los datos, no una decisión visual.

Y el caso interesante: **el texto del mensaje de error** está en el `ViewModel`, no en el widget. Discutible — es texto para una persona. Está ahí porque el `ViewModel` es quien sabe _cuál_ de las dos reglas falló, y separar «qué falló» de «cómo se dice» costaría un tipo intermedio. Ese es exactamente el tipo de decisión que esta lección te pide defender.

## Capas ceremoniales

Un `Service` que solo llama al `Repository` y devuelve lo mismo no aporta nada: agrega un archivo, un salto más al leer y ninguna garantía nueva. Una capa se gana su lugar cuando **coordina** —dos fuentes de datos, una caché, una política de reintento— no cuando reenvía.

La bitácora no tiene `Service` a propósito.

## Intento · antes de mirar

Asigna cada una de estas cuatro cosas a una capa, y justifica:

- recortar espacios de un título
- ordenar la lista por fecha
- mostrar un mensaje de error en pantalla
- decidir el texto de ese mensaje

## Evidencia · ejecuta y compara

Recorre `journal_view_model.dart` y `journal_repository.dart` y anota, para cada método público, qué recibe y qué devuelve. Después ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_model_test.dart
```

Pega la salida. Fíjate en un detalle: esas pruebas no montan ni un widget. Eso solo es posible porque el `ViewModel` no sabe nada de la interfaz.

## Fuente · lee con una pregunta

Abre **Common architecture concepts** y busca la descripción de cada capa. Pregunta concreta: ¿qué responsabilidad asigna a la capa de datos? Anota el encabezado y la frontera que más te sorprenda.

## Criterio · decide y acepta el costo

Defiende si la bitácora necesita un `Service`. La respuesta honesta hoy es que no: no hay nada que coordinar. Nombra el escenario concreto que lo justificaría —sincronizar con una API y una caché local, por ejemplo— y qué costo aceptarías al agregarlo antes de necesitarlo.

En la próxima lección la pregunta pasa de _qué capa_ a _qué carpeta_.
