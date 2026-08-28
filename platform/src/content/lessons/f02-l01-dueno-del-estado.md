---
id: 'F02-L01'
trackId: 'flutter'
moduleId: 'F02'
kind: 'taller'
order: 0
slug: 'estado-local-y-ciclo-de-vida'
title: 'Cada estado necesita un dueño'
summary: 'Clasifica configuración, estado efímero y estado de feature, y ubica cada dato en el widget más pequeño que lo necesita.'
estimatedMinutes: 55
objectives:
  - 'Distinguir configuración inmutable, estado efímero de UI y estado compartido de una feature.'
  - 'Elegir el propietario más pequeño que necesita leer y modificar un dato.'
  - 'Reconocer cuándo un dato está demasiado arriba o demasiado abajo en el árbol.'
prerequisites: ['F01-L04']
activities:
  - id: 'clasificar-estado'
    kind: 'attempt'
    prompt: 'Sin abrir la app, clasifica estos datos como configuración, estado efímero o estado de feature: el texto que se está escribiendo, la lista de entradas guardadas, el color del tema y si un diálogo está abierto.'
    required: true
    hints:
      - 'Pregúntate cuánto tiene que vivir cada dato y quién más lo necesita.'
      - 'Un dato que solo importa mientras una pantalla está abierta rara vez sube.'
  - id: 'rastrear-estado'
    kind: 'evidence'
    prompt: 'En journal_editor_dialog.dart, localiza dónde vive el texto del formulario y dónde vive la lista de entradas. Ejecuta las pruebas de la vista y pega la salida.'
    required: true
    hints:
      - 'Sigue de dónde sale cada valor que se muestra en pantalla.'
      - 'Uno vive en un State; el otro llega desde el ViewModel.'
  - id: 'sustentar-state'
    kind: 'source'
    prompt: 'En State class, encuentra qué dice la documentación sobre la vida de un objeto State respecto de su widget.'
    required: true
    sourceLabel: 'State class'
    hints:
      - 'Busca la parte que describe el ciclo de vida.'
      - 'Fíjate en la relación entre State y el Element.'
  - id: 'defender-propietario'
    kind: 'judgment'
    prompt: 'Decide dónde debería vivir el borrador de una entrada a medio escribir si quisieras que sobreviva al cierre del diálogo, y nombra el costo de subirlo.'
    required: true
    hints:
      - 'Subir un dato lo hace sobrevivir y también lo hace visible para más código.'
      - 'Un borrador que sobrevive necesita reglas para cuando se descarta.'
docRefs:
  - label: 'State class'
    url: 'https://api.flutter.dev/flutter/widgets/State-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué tres preguntas ayudan a encontrar al dueño de un estado?'
  - 'En un archivo vacío, escribe la clasificación de cinco datos de una app tuya, sin mirar la lección.'
  - 'Explica en voz alta por qué un dato debe vivir en el widget más pequeño que lo necesita.'
  - 'Clasifica cursor, filtro activo, borrador, sesión autenticada y lista remota; justifica duración y consumidores.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

«Gestión de estado» suena a una decisión de librería y empieza mucho antes: consiste en decidir, para cada dato, **quién es su dueño**.

## Tres categorías, tres duraciones

| Categoría                | Ejemplo en la bitácora                                     | Cuánto vive                                                |
| ------------------------ | ---------------------------------------------------------- | ---------------------------------------------------------- |
| **Configuración**        | el tema, el título de la app                               | toda la ejecución, no cambia                               |
| **Estado efímero de UI** | el texto que se está escribiendo, si un panel está abierto | mientras el widget existe                                  |
| **Estado de feature**    | la lista de entradas guardadas                             | mientras la feature importa, y lo comparten varios widgets |

Confundir las dos últimas es el error caro. Subir estado efímero a un contenedor global funciona y convierte cada detalle de interfaz en algo que todo el código puede tocar. Dejar estado de feature dentro de un widget también funciona… hasta que otro widget lo necesita.

## Tres preguntas para encontrar al dueño

1. **¿Quién lo lee?** Si solo un widget, vive ahí.
2. **¿Quién lo modifica?** Si lo modifica alguien que no lo contiene, tiene que subir.
3. **¿Cuánto tiene que sobrevivir?** Si debe seguir existiendo después de que el widget desaparezca, no puede vivir en el widget.

La regla que sale de las tres: **el propietario es el widget más pequeño que las cumple todas**. Ni más arriba ni más abajo.

## En la bitácora

- El texto que se está escribiendo vive en el `State` del diálogo. Nadie más lo necesita y no debe sobrevivir al cierre.
- La lista de entradas vive en el `ViewModel`. La leen la lista, el contador del encabezado y el estado vacío, y sobrevive a cualquier diálogo.

## Intento · antes de mirar

Clasifica estos cuatro datos antes de abrir nada, y anota **por qué**:

- el texto que se está escribiendo
- la lista de entradas guardadas
- el color del tema
- si el diálogo está abierto

## Evidencia · ejecuta y compara

Abre `journal_editor_dialog.dart` y rastrea de dónde sale cada valor que se muestra. Uno vive en un `State` local; el otro llega desde el `ViewModel`. Después ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_test.dart
```

Pega la salida.

## Fuente · lee con una pregunta

Abre **State class** con una pregunta concreta: ¿cuánto vive un objeto `State` respecto de su widget? Anota el encabezado; la respuesta es el tema de la próxima lección.

## Criterio · decide y acepta el costo

Supón que quieres que un borrador a medio escribir sobreviva al cierre del diálogo. Eso obliga a subirlo del `State` al `ViewModel`. Defiende si vale la pena y nombra lo que aparece con esa decisión: ahora hay que decidir cuándo se descarta el borrador, qué pasa si se abre otra entrada, y el dato es visible para todo el que lea el estado de la feature.

En la próxima lección se ve por qué el `State` sobrevive a reconstrucciones que borrarían cualquier variable del widget.
