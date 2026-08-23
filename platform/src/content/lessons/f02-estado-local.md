---
id: 'F02-L01'
trackId: 'flutter'
moduleId: 'F02'
order: 0
slug: 'estado-local-y-ciclo-de-vida'
title: 'Cada estado necesita un dueño'
summary: 'Ubica el estado efímero en el widget más pequeño que lo necesita y respeta el ciclo de vida de sus recursos.'
estimatedMinutes: 120
objectives:
  - 'Distinguir configuración inmutable, estado efímero de UI y estado compartido de una feature.'
  - 'Elegir el propietario más pequeño que necesita leer y modificar un dato.'
  - 'Crear y liberar TextEditingController, FocusNode y otros recursos en el ciclo de vida correcto.'
prerequisites: ['F01-L01']
activities:
  - id: 'predecir-rebuild'
    kind: 'predict'
    prompt: 'Predice qué datos sobreviven cuando JournalEditorDialog ejecuta setState y cuáles sobreviven cuando el diálogo se cierra y se vuelve a abrir.'
    required: true
    hints:
      - 'Separa los campos del Widget de los campos del objeto State.'
      - 'Cerrar el diálogo desmonta su State.'
  - id: 'escribir-vista-previa-local'
    kind: 'code'
    prompt: 'Añade al diálogo un interruptor “Vista previa” cuyo bool viva localmente; actualiza solo el subárbol necesario y escribe un widget test del cambio.'
    required: true
    hints:
      - 'El cursor y la visibilidad de una vista previa no pertenecen al Repository.'
      - 'Usa setState para anunciar el nuevo valor, no para ejecutar trabajo asíncrono.'
  - id: 'diagnosticar-recurso'
    kind: 'debug'
    prompt: 'Diagnostica dos fallos: crear un TextEditingController dentro de build y llamar setState después de que un Future termina con el diálogo ya cerrado.'
    required: true
    hints:
      - 'Build puede ejecutarse muchas veces.'
      - 'Antes de actualizar tras await, comprueba si el State continúa mounted.'
  - id: 'leer-state-lifecycle'
    kind: 'docs'
    prompt: 'En la API de State, reconstruye el orden createState → initState → build → dispose y explica qué garantía termina después de dispose.'
    required: true
    hints:
      - 'Lee “Lifecycle” antes de recorrer todos los métodos.'
      - 'Abre dispose para confirmar si un State puede volver a montarse.'
  - id: 'explicar-propietario'
    kind: 'explain'
    prompt: 'Explica por qué los TextEditingController pertenecen al diálogo, mientras que la lista de entradas debe sobrevivir fuera de él.'
    required: true
    hints:
      - 'Pregunta quién necesita leer el dato y cuánto debe durar.'
      - 'No eleves estado solo porque puede elevarse.'
  - id: 'transferir-mapa-de-estado'
    kind: 'transfer'
    prompt: 'Clasifica cursor, filtro activo, borrador, sesión autenticada y lista remota entre estado local, elevado o de aplicación; justifica duración y consumidores.'
    required: true
    hints:
      - 'La categoría depende del alcance real, no del tipo Dart.'
      - 'Si dos hermanos coordinan un valor, busca su ancestro común más cercano.'
docRefs:
  - label: 'State class'
    url: 'https://api.flutter.dev/flutter/widgets/State-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'State.dispose'
    url: 'https://api.flutter.dev/flutter/widgets/State/dispose.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'TextEditingController class'
    url: 'https://api.flutter.dev/flutter/widgets/TextEditingController-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué tres preguntas ayudan a encontrar al dueño de un estado?'
  - '¿Qué diferencia hay entre reconstruir un Widget y destruir su State?'
  - '¿Por qué un controller creado en build es una señal de fallo?'
  - '¿Qué debes comprobar antes de usar context o setState después de await?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Estado es cualquier dato que puede cambiar y afectar lo que la interfaz muestra. La definición es sencilla; la decisión difícil es **quién lo posee**. Si todo vive en una clase global, las piezas quedan acopladas. Si todo vive en widgets diminutos, los datos que deben compartirse desaparecen al desmontarlos.

Antes de elegir una herramienta, responde:

1. ¿Quién necesita leer este valor?
2. ¿Quién puede modificarlo?
3. ¿Cuánto tiempo debe sobrevivir?

El propietario correcto suele ser el alcance más pequeño que contiene a todos sus consumidores y dura lo suficiente.

## Configuración, estado efímero y estado de feature

En `JournalEditorDialog`, `widget.entry` es configuración inmutable: el padre decide si se crea o edita una entrada. Los `TextEditingController` pertenecen al objeto `State`: conservan texto, selección y composición mientras el diálogo está montado. La lista de entradas, en cambio, debe seguir existiendo cuando el diálogo se cierra; por eso no puede vivir dentro de él.

```dart
class _JournalEditorDialogState extends State<JournalEditorDialog> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
```

`initState` crea el recurso una vez para esa vida montada. `dispose` lo libera. Crear el controller dentro de `build` produciría nuevas instancias durante reconstrucciones, podría perder la selección y dejar listeners sin liberar.

## setState no guarda datos por arte de magia

`setState` ejecuta un cambio síncrono y marca el subárbol para reconstrucción. El dato sigue siendo un campo del `State`; la llamada solo informa al framework de que la descripción puede haber cambiado.

```dart
var _showPreview = false;

void _togglePreview(bool value) {
  setState(() => _showPreview = value);
}
```

No hagas una petición larga dentro del callback de `setState`. Realiza el trabajo asíncrono fuera y, antes de usar `context` o actualizar estado después de `await`, confirma que el objeto continúa montado:

```dart
final accepted = await showDialog<bool>(context: context, builder: buildDialog);
if (!context.mounted) return;
if (accepted ?? false) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado')));
}
```

Elevar estado significa moverlo al ancestro común que coordina consumidores. No significa convertirlo inmediatamente en global. Un filtro que afecta una lista y una cabecera puede vivir en su pantalla; una sesión que varias features necesitan quizá pertenezca al nivel de aplicación.

## P — Predice

Sin ejecutar el laboratorio, predice el valor de `_titleController.text` al abrir el diálogo para crear, al escribir, después de un `setState` por un error y al cerrar y volver a abrir. Señala en qué momento se crea otro objeto `State`.

Después predice qué ocurriría si la lista de entradas viviera como `List` dentro del diálogo: al cerrarse se desmontaría su propietario y la pantalla principal no tendría una fuente observable de verdad.

## E — Escribe

Añade una vista previa local al diálogo. El `bool _showPreview` debe vivir en `_JournalEditorDialogState`; el texto sigue en los controllers. Construye la vista previa como un widget pequeño que recibe texto, para que la decisión de presentación no se mezcle con guardar la entrada.

Extiende `journal_view_test.dart`: abre el diálogo, escribe texto, activa la vista previa y comprueba que el contenido aparece. El test debe interactuar como una persona, no llamar métodos privados.

## N — Nombra el fallo

Caso uno: un controller se crea dentro de `build`. El síntoma puede ser cursor que salta o texto reiniciado; la causa es confundir una descripción repetible con el ciclo de vida de un recurso.

Caso dos: una validación asíncrona termina después de cerrar el diálogo y llama `setState`. El síntoma es «setState() called after dispose»; la causa es que el resultado llegó cuando el propietario ya no estaba montado. Cancelar el trabajo cuando sea posible o comprobar `mounted` evita actualizar una vista inexistente.

## S — Sustenta

La API reference se lee de forma distinta a un tutorial. En `State`, empieza por el resumen y la sección **Lifecycle**. Dibuja cada transición y anota qué métodos se llaman una vez y cuáles pueden repetirse. Después abre `dispose` para confirmar el contrato final: una vez ejecutado, ese `State` no vuelve a montarse.

En `TextEditingController`, busca herencia, listeners y la nota de liberación. No necesitas memorizar todas sus propiedades; necesitas descubrir quién lo crea, quién escucha y quién lo destruye.

## A — Argumenta

Defiende por qué una opción «mostrar caracteres restantes» puede quedarse local aunque la app use Riverpod. Su vida está limitada al editor, no interesa a otras vistas y desaparecer al cerrar es el comportamiento correcto. Introducir estado compartido aumentaría consumidores y pruebas sin resolver un requisito.

Ahora nombra una condición que sí obligaría a elevar el borrador: por ejemplo, conservarlo al navegar a otra pantalla o restaurarlo tras cerrar accidentalmente el editor.

## R — Reaplica

Haz un mapa de estado para una pantalla de búsqueda:

- texto y selección del campo;
- filtros compartidos por cabecera y resultados;
- página actual de resultados;
- perfil autenticado;
- preferencia de tema.

Para cada valor, registra propietario, duración, lectores y escritores. Si no puedes nombrarlos, todavía no necesitas escoger Provider, Riverpod, Cubit o Bloc.

Finaliza con el test de widgets y `fvm flutter analyze`. El objetivo no es evitar `StatefulWidget`; es usar estado local deliberadamente y liberar todo recurso que su dueño creó.
