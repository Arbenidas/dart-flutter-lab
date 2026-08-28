---
id: 'F00-L02'
trackId: 'flutter'
moduleId: 'F00'
kind: 'taller'
order: 1
slug: 'un-stateless-widget-configurable'
title: 'Un StatelessWidget configurable'
summary: 'Escribe un widget propio con campos final y constructor const, y separa configuración de contenido.'
estimatedMinutes: 55
objectives:
  - 'Crear un StatelessWidget con campos final y constructor const.'
  - 'Elegir qué datos son parámetros del widget y cuáles vienen de arriba.'
  - 'Explicar qué recibe y qué devuelve el método build.'
prerequisites: ['F00-L01']
activities:
  - id: 'predecir-firma-widget'
    kind: 'attempt'
    prompt: 'Sin abrir journal_entry_card.dart, escribe de memoria la clase mínima de un StatelessWidget que reciba un título y un cuerpo y los muestre.'
    required: true
    hints:
      - 'Un StatelessWidget necesita extends, campos final y un build.'
      - 'El constructor recibe super.key además de tus parámetros.'
  - id: 'modificar-card'
    kind: 'evidence'
    prompt: 'Abre journal_entry_card.dart, agrega un parámetro nuevo al widget, úsalo en build y ejecuta las pruebas. Pega el error de compilación que aparece antes de actualizar todas las llamadas.'
    required: true
    hints:
      - 'Agregar un parámetro required rompe a quien construye el widget: eso es información, no un estorbo.'
      - 'El analizador te indica cada punto de construcción que falta actualizar.'
  - id: 'sustentar-stateless'
    kind: 'source'
    prompt: 'En StatelessWidget class, encuentra qué firma tiene build y qué recibe como argumento.'
    required: true
    sourceLabel: 'StatelessWidget class'
    hints:
      - 'Busca la sección del método build.'
      - 'Anota el tipo del parámetro y el tipo de retorno.'
  - id: 'defender-parametros'
    kind: 'judgment'
    prompt: 'Decide qué datos de una tarjeta de entrada deben ser parámetros del widget y cuáles deberían llegar desde el estado de la feature, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un parámetro vuelve al widget reutilizable y obliga a quien lo usa a proveerlo.'
      - 'Leer el estado desde dentro acopla el widget a esa feature.'
docRefs:
  - label: 'StatelessWidget class'
    url: 'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Create widgets'
    url: 'https://docs.flutter.dev/learn/pathway/tutorial/widget-fundamentals'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué recibe y qué devuelve el método build?'
  - 'En un archivo vacío, vuelve a escribir un StatelessWidget completo con constructor const, sin consultar nada.'
  - 'Explica en voz alta por qué los campos de un widget se declaran final.'
  - 'Descompón una tarjeta de perfil en widgets pequeños e identifica qué datos serían parámetros y cuáles estado local.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_entry_card.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Ya sabes leer un árbol de widgets. Ahora escribes uno.

## La forma mínima

```dart
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[Text(title), Text(body)],
    );
  }
}
```

Cuatro piezas, y ninguna es decorativa:

1. **`extends StatelessWidget`** — este widget no guarda estado propio.
2. **Campos `final`** — un widget es inmutable; sus datos se fijan al construirlo. Si necesitas cambiarlos, construyes un widget nuevo.
3. **Constructor `const`** — solo es posible porque todos los campos son `final`. En la próxima lección verás qué compra eso.
4. **`build(BuildContext context)`** — recibe el contexto de su posición en el árbol y devuelve un `Widget`.

## `super.key` no es ruido

`Key` es cómo Flutter reconoce un widget entre reconstrucciones cuando hay varios del mismo tipo en una lista. No lo necesitas todavía, pero declararlo desde el principio evita tener que agregarlo después en cada widget del proyecto.

## Configuración contra contenido

La decisión de diseño no es cómo escribir la clase: es **qué entra por parámetro**. Un widget que recibe todo lo que muestra se puede reutilizar en cualquier pantalla y se puede probar sin montar la app. Uno que lee el estado global por su cuenta es más corto de usar y solo sirve en esa feature.

## Intento · antes de mirar

Escribe de memoria, en papel o en un archivo aparte, la clase mínima de un `StatelessWidget` que reciba título y cuerpo. Si no te sale completa, ese hueco es exactamente lo que la lección viene a llenar.

## Evidencia · ejecuta y compara

Abre `journal_entry_card.dart` y agrega un parámetro nuevo —por ejemplo un `bool destacada`— marcado como `required`. Guarda **sin** actualizar las llamadas y ejecuta:

```bash
cd flutter_lab
fvm flutter analyze
```

Pega el error. Fíjate en lo que acaba de pasar: el analizador te listó cada lugar del proyecto que construye ese widget. Un parámetro obligatorio convierte un cambio incompleto en una lista de tareas.

Después completa las llamadas y ejecuta las pruebas del widget.

## Fuente · lee con una pregunta

Abre **StatelessWidget class** y busca la firma de `build`. Pregunta concreta: ¿qué recibe y qué devuelve? Anota el tipo del parámetro; ese `BuildContext` vuelve en cada lección de aquí en adelante.

## Criterio · decide y acepta el costo

Defiende qué datos de la tarjeta deben ser parámetros. Pasar todo por parámetro hace al widget reutilizable y probable, y alarga cada punto de construcción. Leer el estado desde dentro acorta las llamadas y ata el widget a una feature concreta.

Elige y nombra qué pierdes. En la próxima lección tocamos la palabra `const`, que hasta ahora aceptaste sin preguntar.
