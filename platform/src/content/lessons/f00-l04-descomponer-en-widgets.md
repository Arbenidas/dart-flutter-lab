---
id: 'F00-L04'
trackId: 'flutter'
moduleId: 'F00'
kind: 'taller'
order: 3
slug: 'descomponer-una-pantalla-en-widgets'
title: 'Un build largo es una pantalla sin nombres'
summary: 'Extrae widgets con nombre de un build extenso y decide dónde cortar según responsabilidades, no según líneas.'
estimatedMinutes: 55
objectives:
  - 'Extraer una parte de un build a un widget con nombre propio.'
  - 'Justificar dónde cortar un árbol según responsabilidades y reconstrucciones.'
  - 'Distinguir extraer un widget de extraer un método que devuelve Widget.'
prerequisites: ['F00-L03']
activities:
  - id: 'predecir-corte'
    kind: 'attempt'
    prompt: 'Sin abrir journal_view.dart, escribe en qué partes cortarías una pantalla que tiene encabezado, barra de acciones, lista y estado vacío, y qué nombre le darías a cada una.'
    required: true
    hints:
      - 'Un buen corte coincide con una responsabilidad, no con un número de líneas.'
      - 'Pregúntate qué parte se reconstruye cuando cambia el estado y cuál no.'
  - id: 'extraer-widget'
    kind: 'evidence'
    prompt: 'En journal_view.dart, extrae una parte del build a un widget privado con nombre y ejecuta las pruebas de la vista. Pega la salida.'
    required: true
    hints:
      - 'Los widgets privados de un archivo se nombran con guion bajo delante.'
      - 'Pasa por parámetro solo lo que el widget nuevo realmente usa.'
  - id: 'sustentar-composicion'
    kind: 'source'
    prompt: 'En Create widgets, encuentra qué recomienda la documentación sobre composición y tamaño de los widgets.'
    required: true
    sourceLabel: 'Create widgets'
    hints:
      - 'Busca la palabra composition dentro de la página.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-widget-vs-metodo'
    kind: 'judgment'
    prompt: 'Compara extraer un widget con nombre frente a extraer un método privado que devuelva Widget. Elige uno y nombra qué pierdes.'
    required: true
    hints:
      - 'Un método comparte el ámbito de la clase; un widget recibe solo lo que le pasas.'
      - 'Solo un widget puede ser const y puede evitar su propia reconstrucción.'
docRefs:
  - label: 'Create widgets'
    url: 'https://docs.flutter.dev/learn/pathway/tutorial/widget-fundamentals'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'StatelessWidget class'
    url: 'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué criterio usas para decidir dónde cortar un build largo?'
  - 'En un archivo vacío, vuelve a escribir un widget privado extraído con sus parámetros, sin mirar el original.'
  - 'Explica en voz alta la diferencia entre extraer un widget y extraer un método que devuelve Widget.'
  - 'Toma una pantalla larga de otro proyecto y propón tres cortes con su justificación.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Un `build` de doscientas líneas no está mal por ser largo. Está mal porque no tiene nombres: para saber qué hace cada parte hay que leerla entera.

## Cortar por responsabilidad

Abre `journal_view.dart` y fíjate en cómo está partido:

- `_Header` — el título y el contador de entradas.
- `_Toolbar` — las acciones disponibles.
- `_EmptyState` — qué se ve cuando no hay nada.

Cada nombre responde una pregunta antes de leer el cuerpo. Ese es el criterio: **cortas donde puedes ponerle un nombre honesto a lo que queda dentro**. Si el nombre te sale genérico —`_Seccion2`, `_Contenido`— es señal de que el corte no coincide con ninguna responsabilidad.

## Widget con nombre contra método privado

Hay dos formas de partir un `build`:

```dart
// método
Widget _buildHeader() => Text(titulo);

// widget
class _Header extends StatelessWidget { ... }
```

Se ven equivalentes y no lo son:

|                     | método                     | widget                         |
| ------------------- | -------------------------- | ------------------------------ |
| acceso a datos      | todo el ámbito de la clase | solo lo que le pasas           |
| puede ser `const`   | no                         | sí                             |
| se reconstruye      | siempre con el padre       | solo si cambian sus parámetros |
| aparece en el árbol | no                         | sí, con su nombre              |

Esa última fila importa más de lo que parece: en el inspector de Flutter y en un stack trace, un `_Header` aparece por su nombre; un método no aparece en ninguna parte.

## Intento · antes de mirar

Antes de abrir el archivo, escribe cómo partirías una pantalla con encabezado, barra de acciones, lista y estado vacío. Ponle nombre a cada parte y anota **qué parámetros** necesitaría cada una.

## Evidencia · ejecuta y compara

Extrae una parte del `build` de `JournalView` a un widget privado nuevo. Pásale solo lo que use de verdad. Después ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_test.dart
```

Pega la salida. Que las pruebas sigan pasando después de mover código es la definición práctica de un refactor: cambiaste la estructura sin cambiar el comportamiento.

## Fuente · lee con una pregunta

Abre **Create widgets** y busca lo que dice sobre composición. Pregunta concreta: ¿qué recomienda sobre el tamaño de los widgets y por qué? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende widget con nombre frente a método privado. El método es dos líneas y no obliga a declarar parámetros; el widget cuesta más código y a cambio limita qué datos puede tocar, puede ser `const` y se ve en las herramientas.

Elige uno como opción por defecto para tu proyecto y nombra en qué caso harías la excepción.

Cierra el módulo:

```bash
fvm flutter analyze
fvm flutter test
```

En F01 la pregunta cambia de _qué se muestra_ a _cuánto espacio tiene para mostrarse_.
