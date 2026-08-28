---
id: 'F00-L03'
trackId: 'flutter'
moduleId: 'F00'
kind: 'taller'
order: 2
slug: 'const-en-widgets'
title: 'const no es decoración en un widget'
summary: 'Descubre qué evita exactamente un constructor const durante las reconstrucciones y cuándo no puedes usarlo.'
estimatedMinutes: 45
objectives:
  - 'Explicar qué reutiliza Flutter cuando un widget se construye como const.'
  - 'Reconocer por qué un widget con datos variables no puede ser const.'
  - 'Usar el analizador para encontrar constructores const que faltan.'
prerequisites: ['F00-L02']
activities:
  - id: 'predecir-const'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, decide cuáles de estos pueden ser const: un Text con literal, un Text con una variable, un Padding con hijo const, y explica por qué.'
    required: true
    hints:
      - 'Un const se resuelve al compilar: su valor no puede depender de una variable.'
      - 'Recuerda la canonicalización que viste en D01.'
  - id: 'quitar-const'
    kind: 'evidence'
    prompt: 'Quita la palabra const de un widget del árbol, ejecuta fvm flutter analyze y pega el aviso que produce el linter.'
    required: true
    hints:
      - 'El paquete flutter_lints incluye una regla sobre constructores const.'
      - 'Después vuelve a ponerlo y confirma que el aviso desaparece.'
  - id: 'sustentar-const-widget'
    kind: 'source'
    prompt: 'En Widget class o en Create widgets, encuentra qué relación establece la documentación entre widgets const y el trabajo de reconstrucción.'
    required: true
    sourceLabel: 'Create widgets'
    hints:
      - 'Busca la palabra const dentro de la página.'
      - 'Fíjate si menciona reutilización de instancias.'
  - id: 'defender-const-widget'
    kind: 'judgment'
    prompt: 'Decide si vale la pena perseguir cada const posible en un proyecto, y nombra el costo de la disciplina y el de no tenerla.'
    required: true
    hints:
      - 'El beneficio aparece en árboles grandes que se reconstruyen a menudo.'
      - 'La regla del linter automatiza la disciplina, pero también genera ruido en revisiones.'
docRefs:
  - label: 'Create widgets'
    url: 'https://docs.flutter.dev/learn/pathway/tutorial/widget-fundamentals'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Widget class'
    url: 'https://api.flutter.dev/flutter/widgets/Widget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué reutiliza Flutter cuando un widget se construye como const?'
  - 'En un archivo vacío, escribe tres widgets: uno const, uno que no puede serlo y explica la diferencia sin mirar.'
  - 'Explica en voz alta por qué un widget cuyos datos vienen de una variable no puede ser const.'
  - 'Recorre una pantalla de tu propio código y marca cada widget que podría ser const; comprueba con el analizador.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/app.dart'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
---

Aceptaste `const` en el constructor de la lección anterior sin preguntar qué compra. Esta lección responde eso, y la respuesta conecta directamente con `D01-L04`.

## Lo mismo que en Dart, aplicado a la interfaz

En D01 viste que Dart **canonicaliza** los valores `const`: dos expresiones constantes iguales producen el mismo objeto en memoria. En Flutter eso tiene una consecuencia concreta.

Cuando un `build` se ejecuta otra vez y produce `const Text('Bitácora')`, no crea un widget nuevo: reutiliza **la misma instancia** de la vez anterior. Flutter compara el widget nuevo con el viejo, ve que son idénticos y puede saltarse la subrama entera.

```dart
// se reutiliza entre reconstrucciones
const Text('Bitácora')

// se crea de nuevo cada vez
Text(state.titulo)
```

El segundo no puede ser `const` y no es un error: su contenido depende de una variable que solo se conoce al ejecutar. `const` es _«conocido al compilar»_, exactamente igual que en Dart puro.

## Dónde importa

En un widget suelto la diferencia es invisible. En una lista larga que se reconstruye en cada pulsación, marcar como `const` las partes que no dependen del estado es lo que separa una interfaz fluida de una que se siente pesada.

`flutter_lints` trae una regla que te avisa cuando un `const` es posible y falta. No hace falta perseguirlos a mano.

## Intento · antes de mirar

Decide, por escrito, cuáles de estos pueden ser `const` y por qué:

```dart
Text('Bitácora')
Text(entrada.titulo)
Padding(padding: EdgeInsets.all(8), child: Text('Bitácora'))
SizedBox(height: espacioCalculado)
```

## Evidencia · provoca el fallo

Abre `lib/app.dart` y quita la palabra `const` de alguno de los widgets del árbol. Guarda y ejecuta:

```bash
cd flutter_lab
fvm flutter analyze
```

Pega el aviso del linter. Después vuelve a ponerlo y confirma que desaparece. Este es el bucle que vas a usar todo el tiempo: cambiar algo, preguntarle a la herramienta, leer lo que responde.

## Fuente · lee con una pregunta

Abre **Create widgets** y busca la palabra `const`. Pregunta concreta: ¿qué relación establece la documentación entre widgets constantes y el trabajo de reconstrucción? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende una postura: ¿perseguir cada `const` posible o dejarlo para donde se note?

A favor de la disciplina: es gratis en tiempo de ejecución, el linter la automatiza y evita tener que decidir caso por caso. En contra: llena las revisiones de cambios triviales y, cuando el árbol es chico, no mejora nada medible.

Elige una y nombra el costo. En la próxima lección aplicas todo esto partiendo una pantalla grande en widgets con nombre.
