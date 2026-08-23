---
id: 'F03-L01'
trackId: 'flutter'
moduleId: 'F03'
order: 0
slug: 'navegacion-formularios-accesibilidad'
title: 'Un flujo también debe explicar cómo recuperarse'
summary: 'Conecta navegación y formularios con foco, semántica y errores que una persona pueda entender y corregir.'
estimatedMinutes: 135
objectives:
  - 'Modelar Navigator como una pila y devolver resultados tipados al cerrar una ruta o diálogo.'
  - 'Validar formularios en el límite adecuado con mensajes que expliquen cómo corregir el dato.'
  - 'Diseñar foco, semántica, contraste y áreas táctiles como parte del flujo funcional.'
prerequisites: ['F02-L01']
activities:
  - id: 'predecir-pila'
    kind: 'predict'
    prompt: 'Dibuja la pila al abrir JournalEditorDialog, cancelar, abrir de nuevo y guardar; predice los valores Future<bool?> que recibe JournalView.'
    required: true
    hints:
      - 'showDialog agrega una ruta pageless sobre la vista actual.'
      - 'Navigator.pop puede devolver un valor a quien hizo await.'
  - id: 'escribir-error-accesible'
    kind: 'code'
    prompt: 'Haz que el error de título vacío sea visible, anunciado por lector de pantalla y comprobable en journal_view_test.dart sin depender únicamente del color.'
    required: true
    hints:
      - 'Conserva texto específico cerca del campo y considera Semantics.liveRegion.'
      - 'El test debe activar Guardar con título vacío y localizar el mensaje.'
  - id: 'diagnosticar-callejon'
    kind: 'debug'
    prompt: 'Diagnostica un formulario que deshabilita Guardar sin explicar por qué y un IconButton sin tooltip; describe la barrera y una corrección verificable para cada caso.'
    required: true
    hints:
      - 'Un estado disabled no enseña cómo avanzar.'
      - 'El icono visible no garantiza un nombre accesible.'
  - id: 'leer-tres-documentos'
    kind: 'docs'
    prompt: 'Compara la guía de navegación, la receta de validación y el checklist de accesibilidad; extrae un contrato de código, un patrón de uso y tres criterios de salida.'
    required: true
    hints:
      - 'La guía orienta decisiones; la receta da pasos; el checklist ayuda a verificar.'
      - 'Registra el encabezado exacto donde encontraste cada evidencia.'
  - id: 'explicar-ruta-o-dialogo'
    kind: 'explain'
    prompt: 'Justifica si crear una entrada merece diálogo o pantalla: considera longitud, deep links, historial, interrupción y espacio pequeño.'
    required: true
    hints:
      - 'Un diálogo es una ruta pageless y no tiene URL propia.'
      - 'La respuesta puede cambiar cuando crece el formulario.'
  - id: 'transferir-recuperacion'
    kind: 'transfer'
    prompt: 'Rediseña un flujo de pago fallido para teclado y lector de pantalla: define foco inicial, orden, anuncio, acción de reintento y forma de volver sin perder datos.'
    required: true
    hints:
      - 'El error debe identificar qué ocurrió y cuál es el siguiente paso.'
      - 'Comprueba que ninguna instrucción dependa solo de posición o color.'
docRefs:
  - label: 'Navigation and routing'
    url: 'https://docs.flutter.dev/ui/navigation'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Build a form with validation'
    url: 'https://docs.flutter.dev/cookbook/forms/validation'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Accessibility'
    url: 'https://docs.flutter.dev/ui/accessibility'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Navigator class'
    url: 'https://api.flutter.dev/flutter/widgets/Navigator-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué relación existe entre push, pop y el Future que devuelve una ruta?'
  - '¿Qué debe contener un mensaje de validación útil?'
  - '¿Cómo compruebas que una acción tiene nombre y área táctil suficientes?'
  - '¿Qué señales indican que un diálogo debería convertirse en pantalla?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Una pantalla puede compilar, responder a taps y seguir dejando a alguien atrapado. Un flujo está completo cuando la persona entiende dónde está, qué puede hacer, qué ocurrió y cómo recuperarse. Navegación, validación y accesibilidad no son capítulos aislados: describen el mismo recorrido desde perspectivas distintas.

## Navigator es una pila con resultados

Para navegación sencilla, `Navigator` mantiene una pila de rutas. `push` agrega una; `pop` retira la superior. La operación de abrir devuelve un `Future<T?>` que termina cuando la ruta se cierra:

```dart
final saved = await showDialog<bool>(
  context: context,
  builder: (context) => const JournalEditorDialog(),
);

if (saved ?? false) {
  // La persona confirmó y el diálogo terminó.
}
```

Dentro del diálogo:

```dart
Navigator.of(context).pop(true);  // guardó
Navigator.of(context).pop(false); // canceló explícitamente
```

El tipo `bool?` recuerda un tercer caso: la ruta puede cerrarse sin seleccionar ninguna acción prevista. Diseñar ese caso evita asumir que todo cierre equivale a éxito.

Un diálogo sirve para una tarea breve y contextual. Una pantalla suele ser mejor cuando el formulario es largo, necesita enlace directo, posee navegación interna o debe sobrevivir como destino del historial. La documentación oficial señala que los requisitos de deep linking y web pueden exigir `Router` o un paquete declarativo; no conviertas todas las rutas simples en configuración avanzada antes de tener esa necesidad.

## Validar es enseñar el siguiente paso

La validación tiene al menos dos niveles:

- **UI inmediata:** formato, campos obligatorios y relaciones que pueden comprobarse sin I/O.
- **Regla de datos o servidor:** unicidad, autorización o estado que otra fuente conoce.

El mensaje debe decir qué dato falla y cómo corregirlo. «Inválido» obliga a adivinar; «El título debe tener entre 1 y 80 caracteres» ofrece un límite accionable. Mantén el texto cerca del campo, conserva lo ya escrito y lleva el foco al primer error cuando el formulario sea largo.

`Form` y `TextFormField` coordinan validadores:

```dart
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escribe un título antes de guardar.';
    }
    return null;
  },
)
```

No todo proyecto debe refactorizar inmediatamente a `Form`. Lo importante es que exista una fuente clara de la regla, feedback visible y una prueba del comportamiento. Si la misma regla protege datos fuera de la UI, no dependas solo del validator visual.

## Accesibilidad es comportamiento

Flutter aporta semántica en muchos widgets Material, pero un diseño personalizado puede perderla. Revisa:

- nombre comprensible para cada control, mediante texto, `tooltip` o `Semantics`;
- orden de foco coherente y foco visible;
- áreas táctiles suficientemente amplias;
- contraste y escalado de texto;
- errores que no dependan únicamente del color;
- acciones destructivas confirmables o reversibles.

Un botón con icono de lápiz puede parecer obvio visualmente, pero un lector de pantalla necesita «Editar entrada X». Un borde rojo no basta para una persona que no distingue ese color; acompáñalo con texto y, cuando corresponda, un anuncio de región activa.

## P — Predice

Dibuja la pila de rutas de `JournalView` al abrir el editor. Marca qué ruta queda debajo, qué contexto construye el diálogo y qué valor completa el `Future<bool?>` al cancelar, guardar y cerrar por otra vía.

Luego usa solo el teclado en tu predicción: ¿qué control recibe foco primero?, ¿Tab alcanza todas las acciones?, ¿Escape o Atrás conserva los datos de la lista? Escribe hipótesis antes de ejecutar.

## E — Escribe

Mejora el error de título vacío del laboratorio. Debe cumplir cuatro criterios:

1. contener una instrucción específica;
2. aparecer cerca del campo;
3. ser detectable por semántica, no solo por color;
4. conservar el texto de los demás campos.

Extiende `journal_view_test.dart` usando las keys existentes: abre, intenta guardar, espera el frame necesario y busca el mensaje. Si añades semántica explícita, incluye una aserción que represente el contrato accesible y no la implementación privada del widget.

## N — Nombra el fallo

Un botón Guardar deshabilitado desde el primer error puede impedir que la persona descubra qué requisito falta. El problema no es solo de color: el control no comunica cómo avanzar. Permitir el intento y mostrar validación, o explicar los requisitos antes del botón, ofrece recuperación.

Un `IconButton` sin `tooltip` puede quedar sin nombre útil. Agregar una etiqueta genérica tampoco basta en una lista: «Editar» repetido no identifica la entrada. Incluye el objeto de la acción cuando sea necesario.

## S — Sustenta

Lee cada documento según su género:

- **Navigation and routing**: decide entre Navigator, Router y enlaces profundos; busca recomendaciones y limitaciones.
- **Form validation cookbook**: sigue una receta concreta; identifica qué piezas son del ejemplo y qué contrato puedes generalizar.
- **Accessibility**: conviértelo en checklist de salida y pruébalo con tecnología asistiva real.
- **Navigator API**: confirma tipos, firmas y semántica exacta de métodos.

Cuando Google muestra una página extensa, no empieces por leer cada línea. Formula una pregunta, usa la tabla de contenido, localiza el encabezado, inspecciona el ejemplo mínimo y termina en **See also** o recursos relacionados. Registra URL, fecha y la decisión que tomaste.

## A — Argumenta

Decide si el editor de la bitácora debe seguir como diálogo. Hoy es corto, contextual y no requiere URL. Si incorporara adjuntos, autoguardado, historial y enlaces compartibles, una pantalla dedicada reduciría encierro y permitiría restauración. Una buena decisión incluye la condición que la haría cambiar.

## R — Reaplica

Diseña la recuperación de un pago rechazado. El error debe anunciarse, mover foco con cuidado, conservar los datos válidos, explicar qué campo o condición falló, ofrecer reintento y permitir volver. Recorre el flujo con teclado y lector de pantalla; después aumenta el texto al máximo previsto.

Ejecuta el test de widgets y `fvm flutter analyze`. Completar el happy path no termina la tarea: debes probar cancelación, dato inválido y recuperación.
