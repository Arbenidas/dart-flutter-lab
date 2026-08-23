---
id: 'F01-L01'
trackId: 'flutter'
moduleId: 'F01'
order: 0
slug: 'constraints-layout-responsive'
title: 'El espacio se negocia, no se adivina'
summary: 'Razona desde las constraints y adapta una composición al espacio disponible sin duplicar la pantalla.'
estimatedMinutes: 120
objectives:
  - 'Explicar el flujo constraints down, sizes up, parents set positions.'
  - 'Elegir entre Row, Column, Wrap, Expanded y ConstrainedBox a partir de un límite concreto.'
  - 'Usar LayoutBuilder para cambiar la composición según el espacio local disponible.'
prerequisites: ['F00-L01']
activities:
  - id: 'predecir-negociacion'
    kind: 'predict'
    prompt: 'Sin ejecutar la app, predice el ancho que recibe el título dentro de Center > ConstrainedBox(maxWidth: 1120) > Row > Expanded cuando la ventana mide 360 y 1400 px.'
    required: true
    hints:
      - 'Separa el ancho de la ventana del ancho máximo permitido al contenido.'
      - 'Expanded ocupa el espacio restante de un eje acotado.'
  - id: 'escribir-composicion-adaptable'
    kind: 'code'
    prompt: 'Implementa con LayoutBuilder un encabezado que use Column bajo 720 px y Row a partir de 720 px, conservando los mismos widgets de título y contador.'
    required: true
    hints:
      - 'Calcula la condición dentro de builder con constraints.maxWidth.'
      - 'Extrae title y counter antes del if para no duplicar su contenido.'
  - id: 'diagnosticar-overflow'
    kind: 'debug'
    prompt: 'Diagnostica un RenderFlex overflow causado por Row > Text largo + botón de ancho fijo; propón dos correcciones y explica qué constraint cambia cada una.'
    required: true
    hints:
      - 'Prueba a limitar el texto con Expanded.'
      - 'Si ambos elementos no caben en una línea, Wrap puede cambiar de carrera.'
  - id: 'leer-constraints'
    kind: 'docs'
    prompt: 'En Understanding constraints, localiza la regla de negociación padre-hijo y un ejemplo de constraint unbounded; parafrasea ambos y enlázalos con un widget del laboratorio.'
    required: true
    hints:
      - 'Lee primero la introducción y después busca “unbounded”.'
      - 'No copies el ejemplo: nombra quién impone el límite en tu árbol.'
  - id: 'explicar-breakpoint'
    kind: 'explain'
    prompt: 'Explica por qué LayoutBuilder suele ser más preciso que clasificar el dispositivo como móvil o tablet para decidir la composición de una sección.'
    required: true
    hints:
      - 'Un widget puede vivir en una ventana, panel o split view de ancho variable.'
      - 'La decisión necesita el espacio local, no una etiqueta de hardware.'
  - id: 'transferir-panel'
    kind: 'transfer'
    prompt: 'Diseña la misma lista de acciones para 320, 768 y 1280 px; define qué se mantiene, qué cambia de eje y qué límite máximo evita líneas demasiado largas.'
    required: true
    hints:
      - 'Conserva un solo modelo de contenido.'
      - 'Escribe la razón de cada breakpoint en términos de espacio necesario.'
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
  - label: 'LayoutBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué baja por el árbol, qué sube y quién decide la posición final?'
  - '¿Por qué un hijo no puede escoger cualquier tamaño que quiera?'
  - '¿Cuándo usarías Expanded y cuándo Wrap?'
  - '¿Qué evidencia justifica un breakpoint en vez de un número copiado?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Una interfaz responsive no empieza preguntando «¿esto es un teléfono?». Empieza preguntando «¿cuánto espacio puede usar este widget aquí?». Esa diferencia permite que la misma composición funcione en un móvil, una ventana redimensionable, un panel lateral o una pantalla dividida.

Flutter resuelve el layout con una negociación:

1. El padre entrega **constraints**: mínimos y máximos de ancho y alto.
2. El hijo elige un tamaño que respeta esos límites.
3. El padre coloca al hijo.

La frase abreviada es: **constraints bajan, tamaños suben, el padre posiciona**. No es un eslogan para memorizar; es una herramienta de depuración. Ante un overflow, pregunta qué límite llegó, qué tamaño intentó devolver el hijo y qué padre lo colocó.

## Leer un árbol como una cadena de límites

Considera este fragmento del laboratorio:

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1120),
    child: CustomScrollView(...),
  ),
)
```

En una ventana de 1400 px, `ConstrainedBox` evita que el contenido crezca más de 1120 px. En una ventana de 360 px, no obliga al hijo a medir 1120: el límite que recibe desde arriba ya es más estrecho. El máximo adicional sirve como techo, no como ancho fijo.

Ahora mira un eje horizontal:

```dart
Row(
  children: <Widget>[
    Expanded(child: title),
    counter,
  ],
)
```

`Row` reserva lo necesario para `counter` y `Expanded` entrega al título el espacio restante. Sin `Expanded`, un texto largo podría solicitar más ancho del disponible y aparecería la conocida franja de overflow. `Expanded` no es una cura universal: solo tiene sentido cuando el eje principal está acotado y el hijo debe ocupar una parte del espacio restante.

## Responsive significa cambiar relaciones

Reducir fuentes hasta que «todo quepa» rara vez resuelve la estructura. A veces dos elementos deben dejar de competir por una fila y pasar a una columna. `LayoutBuilder` permite tomar esa decisión con las constraints locales:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final compact = constraints.maxWidth < 720;

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[title, const SizedBox(height: 16), counter],
      );
    }

    return Row(
      children: <Widget>[Expanded(child: title), counter],
    );
  },
)
```

El breakpoint de 720 no debería convertirse en dogma. Es una hipótesis: por debajo de ese ancho, el título y el contador ya no conservan legibilidad y separación suficientes. Redimensiona, observa el punto donde falla la composición y registra por qué elegiste el límite.

Usa `MediaQuery` cuando necesites información de la ventana o preferencias del usuario, como tamaño de texto. Usa `LayoutBuilder` cuando la decisión depende del espacio que el padre entrega a una región concreta. Un panel dentro de una pantalla ancha puede seguir siendo compacto.

## P — Predice

Abre `journal_view.dart`, pero no ejecutes todavía. Sigue las constraints desde `SafeArea` hasta `_Header`. Predice qué ancho máximo puede recibir el encabezado con ventanas de 360, 768 y 1400 px. Después predice en cuál de ellas `compact` será verdadero.

Anota también qué ocurriría si eliminaras `ConstrainedBox(maxWidth: 1120)`: la app probablemente seguiría compilando, pero las líneas y distancias crecerían sin un límite editorial. «No desborda» no significa automáticamente «se lee bien».

## E — Escribe

Reproduce el encabezado adaptable sin copiar el bloque completo. Declara primero `title` y `counter`; cambia solo la relación entre ambos. En el modo compacto usa `Column`; en el ancho usa `Row` con `Expanded`.

Prueba tres anchos y conserva una tabla de evidencia:

| Ancho | Composición              | ¿Overflow? | Decisión observada                      |
| ----: | ------------------------ | ---------- | --------------------------------------- |
|   360 | columna                  | no         | título y contador respiran              |
|   768 | fila                     | no         | ambos caben sin comprimir texto         |
|  1280 | fila, contenido limitado | no         | la lectura no se estira indefinidamente |

## N — Nombra el fallo

Sustituye temporalmente `Expanded` por un `SizedBox(width: 700)` y reduce la ventana. No te limites a decir «se rompió». Nombra la cadena causal: el `Row` recibió un ancho menor; el hijo exigió 700 px; el contador también necesitó espacio; la suma superó el máximo.

Propón después dos soluciones distintas. `Expanded` comprime el área flexible dentro de la fila. `Wrap` permite una nueva carrera cuando ya no caben los hijos. Elegir una depende de la experiencia deseada, no de cuál elimina el mensaje rojo más rápido.

## S — Sustenta

En **Understanding constraints**, lee en este orden: introducción, ejemplos relevantes y recuadros de restricciones acotadas/no acotadas. Luego abre la API de `LayoutBuilder` y revisa resumen, firma del `builder` y sección **See also**. La guía enseña el modelo mental; la API responde el contrato exacto.

Escribe una nota con tres partes: afirmación de la documentación, evidencia en `JournalView` y consecuencia de diseño. Así conviertes una página oficial larga en una decisión aplicable.

## A — Argumenta

Defiende por qué «si es Android usa Column» es una regla débil. La plataforma no determina el espacio: un teléfono puede rotar, una tablet puede mostrar dos aplicaciones y una app de escritorio puede tener una ventana estrecha. Argumenta desde el ancho que necesita el contenido y desde las preferencias de accesibilidad, no desde marcas de dispositivo.

## R — Reaplica

Diseña una barra con filtros, búsqueda y acción principal. En ancho compacto, la búsqueda ocupa una fila y las acciones envuelven debajo. En ancho medio, búsqueda y acción conviven; en ancho grande, el conjunto queda limitado para no dispersarse. Mantén los mismos datos y callbacks: solo cambia el layout.

Termina ejecutando el test de widgets existente y `fvm flutter analyze`. El test protege el flujo actual; la verificación manual a varios anchos aporta la evidencia responsive que ese test todavía no cubre.
