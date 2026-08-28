---
id: 'F03-L03'
trackId: 'flutter'
moduleId: 'F03'
kind: 'taller'
order: 2
slug: 'accesibilidad-es-comportamiento'
title: 'Accesibilidad es comportamiento, no una capa extra'
summary: 'Ordena foco, nombres semánticos y áreas táctiles como parte del flujo, y compruébalo con las herramientas del framework.'
estimatedMinutes: 60
objectives:
  - 'Declarar foco inicial y orden de recorrido en un formulario.'
  - 'Dar nombre accesible a una acción que solo muestra un icono.'
  - 'Comprobar áreas táctiles y semántica con las herramientas de depuración de Flutter.'
prerequisites: ['F03-L02']
activities:
  - id: 'recorrer-con-teclado'
    kind: 'attempt'
    prompt: 'Sin abrir el código, escribe en qué orden debería recibir el foco cada control del diálogo de edición y dónde debería estar al abrirlo.'
    required: true
    hints:
      - 'El foco inicial debería estar donde la persona va a escribir primero.'
      - 'Al cerrar, el foco tiene que volver a un lugar con sentido.'
  - id: 'probar-teclado'
    kind: 'evidence'
    prompt: 'Ejecuta la app en Chrome y recorre el diálogo usando solo el teclado. Pega la secuencia real de controles que recibieron el foco.'
    required: true
    hints:
      - 'Tab avanza y Shift+Tab retrocede.'
      - 'Anota si algún control queda inalcanzable o si el foco se escapa del diálogo.'
  - id: 'sustentar-accesibilidad'
    kind: 'source'
    prompt: 'En Accessibility, encuentra qué herramientas ofrece Flutter para inspeccionar semántica y tamaños táctiles.'
    required: true
    sourceLabel: 'Accessibility'
    hints:
      - 'Busca las banderas de depuración semántica.'
      - 'Anota el encabezado y el nombre exacto de la herramienta.'
  - id: 'defender-nombre-accion'
    kind: 'judgment'
    prompt: 'Decide si un botón de solo icono debe llevar etiqueta visible o basta con su nombre semántico, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un icono sin texto es ambiguo también para quien ve la pantalla.'
      - 'Una etiqueta visible ocupa espacio que en móvil escasea.'
docRefs:
  - label: 'Accessibility'
    url: 'https://docs.flutter.dev/ui/accessibility'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Build a form with validation'
    url: 'https://docs.flutter.dev/cookbook/forms/validation'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo compruebas que una acción tiene nombre accesible y área táctil suficiente?'
  - 'En un archivo vacío, vuelve a escribir un formulario con foco inicial declarado, sin mirar la lección.'
  - 'Explica en voz alta por qué el orden de foco es parte del flujo funcional y no un detalle estético.'
  - 'Rediseña un flujo de pago fallido para teclado y lector de pantalla: foco inicial, orden, anuncio y reintento.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

La accesibilidad no es una revisión que se hace al final. Es un conjunto de comportamientos: dónde empieza el foco, en qué orden avanza, cómo se llama cada acción y cuánto mide lo que hay que tocar.

## El foco es parte del flujo

Cuando se abre el diálogo de edición, alguien que navega con teclado necesita que el foco esté ya en el primer campo. Si queda en el fondo de la pantalla anterior, esa persona tiene que tabular a ciegas hasta encontrarlo.

Tres decisiones que hay que tomar explícitamente:

1. **Dónde empieza** — en el primer campo editable, casi siempre.
2. **En qué orden avanza** — el orden visual y el de tabulación deben coincidir.
3. **Dónde vuelve al cerrar** — al control que abrió el diálogo, no al principio de la página.

## Un icono no tiene nombre

Un botón que solo muestra un icono de papelera no dice nada a un lector de pantalla. Necesita un nombre:

```dart
IconButton(
  icon: const Icon(Icons.delete_outline),
  tooltip: 'Eliminar entrada',
  onPressed: ...,
)
```

`tooltip` cumple doble función: muestra el texto al pasar el mouse y aporta la etiqueta semántica. Para casos que no son botones, `Semantics(label: ...)` hace lo mismo de forma explícita.

## Áreas táctiles

Un objetivo táctil por debajo de unos 48 píxeles lógicos es difícil de acertar con el pulgar, y mucho más para quien tiene temblor o poca precisión. Los widgets de Material ya lo respetan; el problema aparece cuando reduces el `padding` de un `InkWell` propio para que «se vea más compacto».

## Se comprueba, no se supone

Flutter trae banderas de depuración que dibujan sobre la app: una que muestra el árbol semántico y otra que resalta los tamaños de los objetivos táctiles. Verlas encendidas una vez cambia cómo escribes la interfaz.

Y hay una prueba que no cuesta nada: **recorrer tu pantalla usando solo el teclado**.

## Intento · antes de mirar

Escribe el orden de foco que debería tener el diálogo de edición: dónde empieza, por dónde sigue, dónde vuelve al cerrar. Hazlo antes de abrir el código; después vas a comparar contra la realidad.

## Evidencia · ejecuta y compara

Ejecuta la app en Chrome, abre el diálogo y recórrelo **solo con el teclado**. Anota la secuencia real de controles que reciben el foco y pégala.

Compara con tu predicción. Presta atención a dos fallos frecuentes: que algún control quede inalcanzable, y que el foco se escape del diálogo hacia la pantalla de atrás.

## Fuente · lee con una pregunta

Abre **Accessibility** con una pregunta concreta: ¿qué herramientas ofrece Flutter para inspeccionar la semántica y los tamaños táctiles? Anota el encabezado y el nombre exacto de cada bandera.

## Criterio · decide y acepta el costo

Defiende si las acciones de la barra deben llevar etiqueta visible o basta con el nombre semántico. Un icono sin texto es ambiguo también para quien ve la pantalla —la papelera se entiende, un icono de dos flechas no—. Una etiqueta visible resuelve la ambigüedad y ocupa espacio que en móvil escasea.

Elige y nombra el costo. Cierra el módulo:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
```

En F04 los datos dejan de estar en memoria y empiezan a **tardar** y a fallar.
